// Loaded by Jenkinsfile to keep CPS WorkflowScript under the JVM method size limit.
// Pipeline stash/unstash cannot use InfraPool agentUnstash without a prior agentStash
// (.rsyncFilter); push VERSION with agentWriteFile instead.

void syncVersionToAgent(Object agent) {
  agent.agentWriteFile(file: 'VERSION', text: readFile('VERSION').trim())
}

return this
