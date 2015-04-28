<cfcomponent hint="I am a service that can be configured to make sure events are locked" output="false">

	<cfscript>
		//Defaults
		variables.includeEvents = "";
		variables.excludeEvents = "";
		variables.loginEvent = "";
		variables.includeRoles = ArrayNew(1);
	</cfscript>
	
	<cffunction name="init" returntype="any" output="false" access="public">
		<cfargument name="loginevent" type="string" default="" required="true">
		<cfargument name="include" type="any" hint="Can be a list or an array of events and roles" default="">
		<cfargument name="exclude" type="string" default="">
	
			<cfif Len(arguments.loginEvent)>
				<cfset variables.loginEvent = arguments.loginevent>
			</cfif>
	
			<cfif isArray(arguments.include)>
				<cfloop from="1" to="#ArrayLen(arguments.include)#" index="i">
					<cfset variables.includeEvents = ListAppend(variables.includeEvents, arguments.include[i].event)>
				</cfloop>
				<cfset variables.includeRoles = arguments.include>
			<cfelse>
				<cfset variables.includeevents = arguments.include>
			</cfif>
	
		<cfscript>
			if(Len(arguments.exclude)){
				variables.excludeEvents = arguments.exclude;
			}
		</cfscript>
		<cfreturn this>
	</cffunction>

<!--- Getters and Setters --->
	<cffunction name="getInclude" returntype="string" output="false" access="public">
		<cfreturn variables.includeEvents />
	</cffunction>
	
	<cffunction name="setInclude" output="false" access="public">
		<cfargument  name="local_Include" type="string" />
		<cfset  variables.includeEvents = local_Include />
	</cffunction>

	<cffunction name="getLoginEvent" output="false" access="public" returntype="string">
		<cfreturn variables.LoginEvent />
	</cffunction>
	
	<cffunction name="setLoginEvent" output="false" access="public" returntype="void">
		<cfargument  name="local_LoginEvent" type="string" />
		<cfset  variables.LoginEvent = local_LoginEvent />
	</cffunction>

	<cffunction name="getExclude" returntype="String">
		<cfreturn variables.excludeEvents />
	</cffunction>
	
	<cffunction name="setExclude">
		<cfargument  name="local_Exclude" type="String" />
		<cfset  variables.excludeEvents = local_Exclude />
	</cffunction>

	<cffunction name="getIncludeRoles" output="false" access="public"  returntype="Array">
		<cfreturn variables.IncludeRoles />
	</cffunction>
	
	<cffunction name="setIncludeRoles"  output="false" access="public" returntype="void">
		<cfargument  name="local_IncludeRoles" type="array" />
		<cfset  variables.IncludeRoles = local_IncludeRoles />
	</cffunction>

<!--- Checking code --->



	<cffunction name="doChecks" output="false" access="public" returntype="void">
		<cfargument name="event" required="true">
		
		<!--- If there are no roles, then we do simple security --->
		<cfif NOT ArrayLen(variables.includeRoles)>
			<cfset doSimpleCheck(event)>
		<!--- If there are roles, we do role based security --->
		<cfelse>
			<cfset doRoleCheck(event)>
		</cfif>
		
		<cfreturn />
	</cffunction>

	<cffunction name="doSimpleCheck" access="private" output="false">
		<cfargument name="event" required="true">
		<cfset var currentEvent = event.getValue(event.getValue("eventValue"))>
		
		<cfif NOT Len(getLoginEvent())>
				<cfthrow message="You must set a login event for the EventGuard.">
				<cfreturn /> <!--- Might be unreachable code, but just in case --->
		</cfif>
		
		<cfif ListFindNoCase(getExclude(), currentEvent)>
			<!--- If the current event is listed in the excluded events, ignore it --->
			<cfreturn />
		</cfif>
		
		<cfif getInclude() IS "*" AND  currentEvent NEQ getLoginEvent() AND NOT Len(getAuthUser())> <!--- we are protecting everything --->
			<!--- Check for exclusions --->
				<cfset event.setValue('previousevent', currentEvent)>
				<cfset event.forward(variables.loginEvent, "previousevent")>
			<cfreturn />
		</cfif>
		
		<!--- We found it --->
		<cfif ListFindNoCase(getInclude(), currentEvent)  AND  NOT Len(getAuthUser())>
			<cfset event.setValue('previousevent', currentEvent)>
			<cfset event.forward(variables.loginEvent, "previousevent")>
			<cfreturn />
		</cfif>
	
	</cffunction>

	<cffunction name="doRoleCheck" access="private" output="false">
		<cfargument name="event" required="true">
		<cfset var iter = 0>
		<cfset var roleData = ArrayNew(1)>
		<cfset var currentEvent = event.getValue(event.getValue("eventValue"))>
		<!--- Roles are defined as follows:
			evententry.event = "eventname";
			evententry.roles = "somerole,anotherrole,anotherrole";
		 --->
		 
		 <cfif not ArrayLen(getIncludeRoles())>
			<cfreturn />
		</cfif>
		
		<cfif ListFindNoCase(getExclude(), currentEvent)>
			<!--- If the current event is listed in the excluded events, ignore it --->
			<cfreturn />
		</cfif>	
			
		<cfset roleData = getIncludeRoles()>
		<cfloop from="1" to="#ArrayLen(roleData)#" index="iter">
			<!--- Do checks --->
		
			<!--- If we are protecting everything in this entry, and the person is not logged in, go to login --->
			<cfif roleData[iter].event IS "*" AND currentEvent NEQ getLoginEvent()> <!--- we are protecting everything --->
				<!--- Loop through the roles assigned --->
				<cfloop list="#roleData[iter].roles#" index="roles">
					<cfif isUserInRole(roles)>
						<cfreturn />
					</cfif>
				</cfloop>
				<!--- we seem to have got to the end of the roles, we didnt find one obviously, so they are redirected --->
				<cfset event.setValue('previousevent', currentEvent)>
				<cfset event.forward(variables.loginEvent, "previousevent")>
				<cfreturn />
			</cfif>		
			
			<!--- Check whether we are in the current role? --->
			<cfif roleData[iter].event EQ currentEvent>
				<cfloop list="#roleData[iter].roles#" index="roles">
					<cfif isUserInRole(roles)>
						<cfreturn />
					</cfif>
				</cfloop>
				
				<!--- we seem to have got to the end of the roles, we didnt find one obviously, so they are redirected --->
				<cfset event.setValue('previousevent', currentEvent)>
				<cfset event.forward(variables.loginEvent, "previousevent")>
				<cfreturn />	
			</cfif>
		</cfloop>
	
			<cfreturn />
	</cffunction>


</cfcomponent>