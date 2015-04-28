LICENSE 
Copyright 2007 Mark Drew

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   

EventGuard is a ModelGlue Action Pack that you can use to limit access to certain events (event-handlers) by name.

You define either a comma delimited list of event names to include in the protection or a array of event names and roles that the user needs to match to be able to run that event.

You then define the login event that they will be redirected to if they dont pass the validation.

INSTALLATION

1) Drop the EventGuard folder into your web root or CF mapping
2) In your ModelGlue file pur the following after the first <modelglue> node:
		<include template="/EventGuard/config/EventGuard.xml"/>
		
3) Configure the EventGuard bean (you can see an example in EventGuard/config/Coldspring.xml), you can do this in two ways:

	a) Define specific events that you want to include in the guard and exclude:
	<bean id="EventGuard" class="EventGuard.services.EventGuard">
		<constructor-arg name="loginEvent"><value>login</value></constructor-arg>
		<constructor-arg name="include"><value>profile, profile.save, viewstats</value></constructor-arg>
		<constructor-arg name="exclude"><value>login.do, register, register.do, forgottenpassword, forgottenpassword.do</value></constructor-arg>
	</bean>
	
	b) Or do as above, but pass in a list of items that you want to include and assign roles
		<bean id="EventGuard" class="EventGuard.services.EventGuard">
			<constructor-arg name="loginEvent"><value>login</value></constructor-arg>
			<constructor-arg name="exclude"><value>login.do, register, register.do, forgottenpassword, forgottenpassword.do</value></constructor-arg>
			<constructor-arg name="include">

				<list>
					<map>
						<entry key="event"><value>myprofile</value></entry>
						<entry key="roles"><value>user,admin</value></entry>
					</map>
					<map>
						<entry key="event"><value>addressbook</value></entry>
						<entry key="roles"><value>user,admin</value></entry>
					</map>
					<map>
						<entry key="event"><value>administration</value></entry>
						<entry key="roles"><value>admin</value></entry>
					</map>
				</list>
			</constructor-arg>
		</bean>
		
4) You can place this bean in your current ColdSpring.xml file or add the following to include the ColdSpring.xml file that comes with EventGuard (this is a relative path to the ColdSpring.xml file):
	<import resource="../../EventGuard/config/ColdSpring.xml" />

	