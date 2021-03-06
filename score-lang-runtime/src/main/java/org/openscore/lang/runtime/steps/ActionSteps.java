/*******************************************************************************
* (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Apache License v2.0 which accompany this distribution.
*
* The Apache License is available at
* http://www.apache.org/licenses/LICENSE-2.0
*
*******************************************************************************/
package org.openscore.lang.runtime.steps;

import com.hp.oo.sdk.content.annotations.Param;
import com.hp.oo.sdk.content.plugin.GlobalSessionObject;
import com.hp.oo.sdk.content.plugin.SerializableSessionObject;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.log4j.Logger;
import org.openscore.api.execution.ExecutionParametersConsts;
import org.openscore.lang.ExecutionRuntimeServices;
import org.openscore.lang.entities.ActionType;
import org.openscore.lang.runtime.env.ReturnValues;
import org.openscore.lang.runtime.env.RunEnvironment;
import org.openscore.lang.runtime.events.LanguageEventData;
import org.python.core.PyException;
import org.python.core.PyModule;
import org.python.core.PyObject;
import org.python.core.PyStringMap;
import org.python.util.PythonInterpreter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.Serializable;
import java.lang.annotation.Annotation;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static org.openscore.api.execution.ExecutionParametersConsts.EXECUTION_RUNTIME_SERVICES;
import static org.openscore.lang.entities.ScoreLangConstants.ACTION_CLASS_KEY;
import static org.openscore.lang.entities.ScoreLangConstants.ACTION_METHOD_KEY;
import static org.openscore.lang.entities.ScoreLangConstants.ACTION_TYPE;
import static org.openscore.lang.entities.ScoreLangConstants.EVENT_ACTION_END;
import static org.openscore.lang.entities.ScoreLangConstants.EVENT_ACTION_ERROR;
import static org.openscore.lang.entities.ScoreLangConstants.EVENT_ACTION_START;
import static org.openscore.lang.entities.ScoreLangConstants.NEXT_STEP_ID_KEY;
import static org.openscore.lang.entities.ScoreLangConstants.PYTHON_SCRIPT_KEY;
import static org.openscore.lang.entities.ScoreLangConstants.RUN_ENV;

/**
 * User: stoneo
 * Date: 02/11/2014
 * Time: 10:25
 */
@Component
public class ActionSteps extends AbstractSteps {

    private static final Logger logger = Logger.getLogger(ActionSteps.class);

    @Autowired
    private PythonInterpreter interpreter;

    public void doAction(@Param(RUN_ENV) RunEnvironment runEnv,
                         @Param(ExecutionParametersConsts.NON_SERIALIZABLE_EXECUTION_DATA) Map<String, Object> nonSerializableExecutionData,
                         @Param(ACTION_TYPE) ActionType actionType,
                         @Param(ACTION_CLASS_KEY) String className,
                         @Param(ACTION_METHOD_KEY) String methodName,
                         @Param(EXECUTION_RUNTIME_SERVICES) ExecutionRuntimeServices executionRuntimeServices,
                         @Param(PYTHON_SCRIPT_KEY) String python_script,
                         @Param(NEXT_STEP_ID_KEY) Long nextStepId) {

        Map<String, String> returnValue = new HashMap<>();
        Map<String, Serializable> callArguments = runEnv.removeCallArguments();
        Map<String, SerializableSessionObject> serializableSessionData = runEnv.getSerializableDataMap();
        fireEvent(executionRuntimeServices, runEnv, EVENT_ACTION_START, "Preparing to run action " + actionType, Pair.of(LanguageEventData.CALL_ARGUMENTS, (Serializable) callArguments));
        try {
            switch (actionType) {
                case JAVA:
                    returnValue = runJavaAction(serializableSessionData, callArguments, nonSerializableExecutionData, className, methodName);
                    break;
                case PYTHON:
                    returnValue = prepareAndRunPythonAction(callArguments, python_script);
                    break;
                default:
                    break;
            }
        } catch (RuntimeException ex) {
            fireEvent(executionRuntimeServices, runEnv, EVENT_ACTION_ERROR, ex.getMessage(), Pair.of(LanguageEventData.EXCEPTION, ex));
            logger.error(ex);
            throw(ex);
        }

        //todo: hook

        ReturnValues returnValues = new ReturnValues(returnValue, null);
        runEnv.putReturnValues(returnValues);
        fireEvent(executionRuntimeServices, runEnv, EVENT_ACTION_END, "Action performed", Pair.of(LanguageEventData.RETURN_VALUES, (Serializable)returnValue));

        runEnv.putNextStepPosition(nextStepId);
    }

    private Map<String, String> runJavaAction(Map<String, SerializableSessionObject> serializableSessionData,
                                              Map<String, Serializable> currentContext,
                                              Map<String, Object> nonSerializableExecutionData,
                                              String className,
                                              String methodName) {

        Object[] actualParameters = extractMethodData(serializableSessionData, currentContext, nonSerializableExecutionData, className, methodName);

        return invokeActionMethod(className, methodName, actualParameters);
    }

    private Object[] extractMethodData(Map<String, SerializableSessionObject> serializableSessionData,
                                       Map<String, Serializable> currentContext,
                                       Map<String, Object> nonSerializableExecutionData,
                                       String className,
                                       String methodName) {

        //get the Method object
        Method actionMethod = getMethodByName(className, methodName);
        if(actionMethod == null) {
            throw new RuntimeException("Method " + methodName + " is not part of class " + className);
        }

        //extract the parameters from execution context
        return resolveActionArguments(serializableSessionData, actionMethod, currentContext, nonSerializableExecutionData);
    }


    private Map<String, String> invokeActionMethod(String className, String methodName, Object... parameters) {
        Method actionMethod = getMethodByName(className, methodName);
        Class actionClass = getActionClass(className);
        Object returnObject;
        try {
            returnObject = actionMethod.invoke(actionClass.newInstance(), parameters);
        } catch (Exception e) {
            throw new RuntimeException("Invocation of method " + methodName + " of class " + className + " threw an exception", e);
        }
        @SuppressWarnings("unchecked") Map<String, String> returnMap = (Map<String, String>) returnObject;
        if (returnMap == null) {
            throw new RuntimeException("Action method did not return Map<String,String>");
        }
        return returnMap;
    }

    private Class getActionClass(String className) {
        Class actionClass;
        try {
            actionClass = Class.forName(className);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Class name " + className + " was not found", e);
        }
        return actionClass;
    }

    private Method getMethodByName(String className, String methodName)  {
        Class actionClass = getActionClass(className);
        Method[] methods = actionClass.getDeclaredMethods();
        Method actionMethod = null;
        for (Method m : methods) {
            if (m.getName().equals(methodName)) {
                actionMethod = m;
            }
        }
        return actionMethod;
    }

    protected Object[] resolveActionArguments(Map<String, SerializableSessionObject> serializableSessionData,
                                              Method actionMethod,
                                              Map<String, Serializable> currentContext,
                                              Map<String, Object> nonSerializableExecutionData) {
        List<Object> args = new ArrayList<>();

        int index = 0;
        Class[] parameterTypes = actionMethod.getParameterTypes();
        for (Annotation[] annotations : actionMethod.getParameterAnnotations()) {
            index++;
            for (Annotation annotation : annotations) {
                if (annotation instanceof Param) {
                    if (parameterTypes[index - 1].equals(GlobalSessionObject.class)) {
                        handleNonSerializableSessionContextArgument(nonSerializableExecutionData, args, (Param) annotation);
                    } else if (parameterTypes[index - 1].equals(SerializableSessionObject.class)) {
                        handleSerializableSessionContextArgument(serializableSessionData, args, (Param) annotation);
                    } else {
                        String parameterName = ((Param) annotation).value();
                        Serializable value = currentContext.get(parameterName);
                        Class parameterClass =  parameterTypes[index - 1];
                        if (parameterClass.isInstance(value) || value == null) {
                            args.add(value);
                        } else {
                            StringBuilder exceptionMessageBuilder = new StringBuilder();
                            exceptionMessageBuilder.append("Parameter type mismatch for action ");
                            exceptionMessageBuilder.append(actionMethod.getName());
                            exceptionMessageBuilder.append(" of class ");
                            exceptionMessageBuilder.append(actionMethod.getDeclaringClass().getName());
                            exceptionMessageBuilder.append(". Parameter ");
                            exceptionMessageBuilder.append(parameterName);
                            exceptionMessageBuilder.append(" expects type ");
                            exceptionMessageBuilder.append(parameterClass.getName());
                            throw new RuntimeException(exceptionMessageBuilder.toString());
                        }
                    }
                }
            }
            if (args.size() != index) {
                throw new RuntimeException("All action arguments should be annotated with @Param");
            }
        }
        return args.toArray(new Object[args.size()]);
    }

    private void handleNonSerializableSessionContextArgument(Map<String, Object> nonSerializableExecutionData, List<Object> args, Param annotation) {
        String key = annotation.value();
        Object nonSerializableSessionContextObject = nonSerializableExecutionData.get(key);
        if (nonSerializableSessionContextObject == null) {
            nonSerializableSessionContextObject = new GlobalSessionObject<>();
            nonSerializableExecutionData.put(key, nonSerializableSessionContextObject);
        }
        args.add(nonSerializableSessionContextObject);
    }

    private void handleSerializableSessionContextArgument(Map<String, SerializableSessionObject> serializableSessionData, List<Object> args, Param annotation) {
        String key = annotation.value();
        SerializableSessionObject serializableSessionContextObject = serializableSessionData.get(key);
        if (serializableSessionContextObject == null) {
            serializableSessionContextObject = new SerializableSessionObject();
            //noinspection unchecked
            serializableSessionData.put(key, serializableSessionContextObject);
        }
        args.add(serializableSessionContextObject);
    }

    @SuppressWarnings("unchecked")
    private Map<String, String> prepareAndRunPythonAction(
            Map<String, Serializable> callArguments,
            String pythonScript) {

        if (StringUtils.isNotBlank(pythonScript)) {
            return runPythonAction(callArguments, pythonScript);
        }

        throw new RuntimeException("Python script not found in action data");
    }

    //we need this method to be synchronized so we will ot have multiple scripts run in parallel on the same context
    private synchronized Map<String, String> runPythonAction(Map<String, Serializable> callArguments,
                                                             String script) {

        try {
            executePythonScript(interpreter, script, callArguments);
        } catch (PyException e) {
            throw new RuntimeException("Error executing python script: " + e, e);
        }
        Iterator<PyObject> localsIterator = interpreter.getLocals().asIterable().iterator();
        HashMap<String, String> returnValue = new HashMap<>();
        while (localsIterator.hasNext()) {
            String key = localsIterator.next().asString();
            PyObject value = interpreter.get(key);
            if ((key.startsWith("__") && key.endsWith("__")) || value instanceof PyModule) {
                continue;
            }
            returnValue.put(key, value.toString());
        }
        cleanInterpreter(interpreter);
        return returnValue;
    }

    private void executePythonScript(PythonInterpreter interpreter, String script, Map<String, Serializable> userVars) {
        Iterator<Map.Entry<String, Serializable>> iterator = userVars.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, Serializable> entry = iterator.next();
            interpreter.set(entry.getKey(), entry.getValue());
            iterator.remove();
        }

        interpreter.exec(script);
    }

    private void cleanInterpreter(PythonInterpreter interpreter) {
        interpreter.setLocals(new PyStringMap());
    }
}
