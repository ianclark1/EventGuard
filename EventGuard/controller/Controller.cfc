<cfcomponent displayname="Controller" extends="ModelGlue.unity.controller.Controller" output="false">
	<cffunction name="onRequestStart" access="public" returnType="void" output="false">
	  <cfargument name="event" type="any">

	   	<!--- Check the bean exists --->
	   	<cfif NOT getModelGlue().getBeanFactory().beanDefinitionExists("EventGuard")>
			<cfset event.trace("EventGuard", "The EventGuard bean hasn't been defined in the BeanFactory (ColdSpring to you and me)")>
			<cfreturn />
		</cfif>
		
		<!--- Do the event checking --->
	  	<cfset EG = getModelGlue().getBean("EventGuard")>
	  	<cfset EG.doChecks(event)> 

	</cffunction>

</cfcomponent>