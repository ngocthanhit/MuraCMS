<!--- This file is part of Mura CMS.

Mura CMS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, Version 2 of the License.

Mura CMS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. �See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Mura CMS. �If not, see <http://www.gnu.org/licenses/>.

Linking Mura CMS statically or dynamically with other modules constitutes
the preparation of a derivative work based on Mura CMS. Thus, the terms and 	
conditions of the GNU General Public License version 2 (�GPL�) cover the entire combined work.

However, as a special exception, the copyright holders of Mura CMS grant you permission
to combine Mura CMS with programs or libraries that are released under the GNU Lesser General Public License version 2.1.

In addition, as a special exception, �the copyright holders of Mura CMS grant you permission
to combine Mura CMS �with independent software modules that communicate with Mura CMS solely
through modules packaged as Mura CMS plugins and deployed through the Mura CMS plugin installation API,
provided that these modules (a) may only modify the �/trunk/www/plugins/ directory through the Mura CMS
plugin installation API, (b) must not alter any default objects in the Mura CMS database
and (c) must not alter any files in the following directories except in cases where the code contains
a separately distributed license.

/trunk/www/admin/
/trunk/www/tasks/
/trunk/www/config/
/trunk/www/requirements/mura/

You may copy and distribute such a combined work under the terms of GPL for Mura CMS, provided that you include
the source code of that other code when and as the GNU GPL requires distribution of source code.

For clarity, if you create a modified version of Mura CMS, you are not obligated to grant this special exception
for your modified version; it is your choice whether to do so, or to make such modified version available under
the GNU General Public License version 2 �without this exception. �You may, if you choose, apply this exception
to your own modified versions of Mura CMS.
--->
<cfcomponent extends="mura.cfobject" output="false">

<cffunction name="init" returntype="any" output="false" access="public">
<cfargument name="configBean" type="any" required="yes"/>
<cfargument name="userDAO" type="any" required="yes"/>
<cfargument name="userGateway" type="any" required="yes"/>
<cfargument name="userUtility" type="any" required="yes"/>
<cfargument name="utility" type="any" required="yes"/>
<cfargument name="fileManager" type="any" required="yes"/>
<cfargument name="pluginManager" type="any" required="yes"/>
<cfargument name="trashManager" type="any" required="yes"/>
<cfargument name="settingsManager" type="any" required="yes"/>
<cfargument name="clusterManager" type="any" required="yes"/>

	<cfset variables.configBean=arguments.configBean />
	<cfset variables.userDAO=arguments.userDAO />
	<cfset variables.userGateway=arguments.userGateway />
	<cfset variables.userUtility=arguments.userUtility />	
	<cfset variables.globalUtility=arguments.utility />
	<cfset variables.ClassExtensionManager=variables.configBean.getClassExtensionManager() />
	<cfset variables.fileManager=arguments.fileManager />
	<cfset variables.pluginManager=arguments.pluginManager />
	<cfset variables.trashManager=arguments.trashManager />
	<cfset variables.settingsManager=arguments.settingsManager />
	<cfset variables.clusterManager=arguments.clusterManager />
	
	<cfset variables.userDAO.setUserManager(this)>
	
	<cfreturn this />
</cffunction>

<cffunction name="getUserGroups" access="public" returntype="query" output="false">
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="isPublic" type="numeric" default="0"/>
		<cfset var rs ="" />
		
		<cfset rs=variables.userGateway.getUserGroups(arguments.siteid,arguments.isPublic) />
		
		<cfreturn rs />
	</cffunction>
	
<cffunction name="read" access="public" returntype="any" output="false">
	<cfargument name="userid" type="string" default=""/>
	<cfargument name="username" type="string" default=""/>
	<cfargument name="remoteID" type="string" default=""/>
	<cfargument name="siteID" type="string" default=""/>
	<cfargument name="groupname" type="string" default=""/>
	<cfargument name="isPublic" type="string" default="1"/>
	<cfargument name="userBean" default=""/>
	<cfset var key= "" />
	<cfset var site=""/>
	<cfset var cacheFactory="">
	<cfset var bean="">	
	
	<cfif len(arguments.siteID)>
		<cfif len(arguments.username)>
			<cfreturn readByUsername(arguments.username,arguments.siteid,arguments.userBean) />
		<cfelseif len(arguments.groupname)>
			<cfreturn readByGroupName(arguments.groupname,arguments.siteid,arguments.isPublic,arguments.userBean) />
		<cfelseif len(arguments.remoteID)>
			<cfreturn readByRemoteID(arguments.remoteID,arguments.siteid,arguments.userBean) />
		</cfif>
	</cfif>
	
	<cfset key= "user" & arguments.siteid & arguments.userID />
	<cfset site=variables.settingsManager.getSite(arguments.siteid)/>
	<cfset cacheFactory=site.getCacheFactory(name="data")>			
	
	<cfif site.getCache()>
		<!--- check to see if it is cached. if not then pass in the context --->
		<!--- otherwise grab it from the cache --->
		<cfif NOT cacheFactory.has( key )>
			<cfset bean=variables.userDAO.read(arguments.userid,arguments.userBean)>
			<cfif not bean.getIsNew()>
				<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
			</cfif>
			<cfreturn bean/>
		<cfelse>
			<cfif isObject(arguments.userBean)>
				<cfset bean=arguments.userBean/>
			<cfelse>
				<cfset bean=variables.userDAO.getBean()/>
			</cfif>
			<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
			<cfreturn bean />
		</cfif>
	<cfelse>
		<cfreturn variables.userDAO.read(arguments.userid,arguments.userBean) />
	</cfif>		
</cffunction>

<cffunction name="readUserHash" access="public" returntype="query" output="false">
	<cfargument name="userid" type="string" default=""/>		
	<cfreturn variables.userDAO.readUserHash(arguments.userid) />
</cffunction>

<cffunction name="readByUsername" access="public" returntype="any" output="false">
	<cfargument name="username" type="string" default=""/>
	<cfargument name="siteid" type="string" default=""/>
	<cfargument name="userBean" default=""/>
	<cfset var key= "user" & arguments.siteid & arguments.username />
	<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
	<cfset var cacheFactory=site.getCacheFactory(name="data")>
	<cfset var bean="">	
	
	<cfif site.getCache()>
		<!--- check to see if it is cached. if not then pass in the context --->
		<!--- otherwise grab it from the cache --->
		<cfif NOT cacheFactory.has( key )>
			<cfset bean=variables.userDAO.readByUsername(arguments.username,arguments.siteid,arguments.userBean) />
			<cfif not bean.getIsNew()>
				<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
			</cfif>
			<cfreturn bean/>
		<cfelse>
			<cfif isObject(arguments.userBean)>
				<cfset bean=arguments.userBean/>
			<cfelse>
				<cfset bean=variables.userDAO.getBean()/>
			</cfif>
			<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
			<cfreturn bean />
		</cfif>
	<cfelse>
		<cfreturn variables.userDAO.readByUsername(arguments.username,arguments.siteid,arguments.userBean) />
	</cfif>	

</cffunction>

<cffunction name="readByGroupName" access="public" returntype="any" output="false">
	<cfargument name="groupname" type="string" default=""/>
	<cfargument name="siteid" type="string" default=""/>
	<cfargument name="isPublic" type="string" required="yes" default="both"/>
	<cfargument name="userBean" default=""/>
	<cfset var key= "user" & arguments.siteid & arguments.groupname />
	<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
	<cfset var cacheFactory=site.getCacheFactory(name="data")>
	<cfset var bean="">	
	
	<cfif site.getCache()>
		<!--- check to see if it is cached. if not then pass in the context --->
		<!--- otherwise grab it from the cache --->
		<cfif NOT cacheFactory.has( key )>
			<cfset bean=variables.userDAO.readByGroupName(arguments.groupname,arguments.siteid,arguments.isPublic,arguments.userbean)  />
			<cfif not bean.getIsNew()>
				<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
			</cfif>
			<cfreturn bean/>
		<cfelse>
			<cfif isObject(arguments.userBean)>
				<cfset bean=arguments.userBean/>
			<cfelse>
				<cfset bean=variables.userDAO.getBean()/>
			</cfif>
			<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
			<cfreturn bean />
		</cfif>
	<cfelse>
		<cfreturn variables.userDAO.readByGroupName(arguments.groupname,arguments.siteid,arguments.isPublic,arguments.userbean) />
	</cfif>			
	
</cffunction>

<cffunction name="readByRemoteID" access="public" returntype="any" output="false">
	<cfargument name="remoteID" type="string" default=""/>
	<cfargument name="siteid" type="string" default=""/>
	<cfargument name="userBean" default=""/>
	<cfset var key= "user" & arguments.siteid & arguments.remoteID />
	<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
	<cfset var cacheFactory=site.getCacheFactory(name="data")>
	<cfset var bean="">	
	
	<cfif site.getCache()>
		<!--- check to see if it is cached. if not then pass in the context --->
		<!--- otherwise grab it from the cache --->
		<cfif NOT cacheFactory.has( key )>
			<cfset bean=variables.userDAO.readByRemoteID(arguments.remoteID,arguments.siteid,arguments.userBean) />
			<cfif not bean.getIsNew()>
				<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
			</cfif>
			<cfreturn bean/>
		<cfelse>
			<cfif isObject(arguments.userBean)>
				<cfset bean=arguments.userBean/>
			<cfelse>
				<cfset bean=variables.userDAO.getBean()/>
			</cfif>
			<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
			<cfreturn bean />
		</cfif>
	<cfelse>
		<cfreturn variables.userDAO.readByRemoteID(arguments.remoteID,arguments.siteid,arguments.userBean) />
	</cfif>			
	
</cffunction>

<cffunction name="purgeUserCache" output="false">
	<cfargument name="userID">
	<cfargument name="userBean">
	<cfset var cache="">
	
	<cfif not isDefined("arguments.userBean")>
		<cfset arguments.userBean=read(userID=arguments.userID)>
	</cfif>
	
	<cfif NOT arguments.userBean.getIsNew()>
		<cfset cache=variables.settingsManager.getSite(arguments.userBean.getSiteID()).getCacheFactory(name="data")>
		
		<cfset cache.purge("user" & arguments.userBean.getSiteID() & arguments.userBean.getUserID())>
		<cfif len(arguments.userBean.getRemoteID())>
			<cfset cache.purge("user" & userBean.getSiteID() & arguments.userBean.getRemoteID())>
		</cfif>
		<cfif len(arguments.userBean.getUsername())>
			<cfset cache.purge("user" & arguments.userBean.getSiteID() & arguments.userBean.getUsername())>
		</cfif>
		<cfif len(arguments.userBean.getGroupname())>
			<cfset cache.purge("user" & arguments.userBean.getSiteID() & arguments.userBean.getGroupname())>
		</cfif>
		
		<cfset variables.clusterManager.purgeUserCache(userID=arguments.userBean.getUserID())>
	</cfif>
</cffunction>

<cffunction name="save" access="public" returntype="any" output="false">
	<cfargument name="data" type="any" default="#structnew()#"/>	
	<cfargument name="updateGroups" type="boolean" default="true" required="yes" />
	<cfargument name="updateInterests" type="boolean" default="true" required="yes" />
	<cfargument name="OriginID" type="string" default="" required="yes" />
	
	<cfset var userID="">
	<cfset var rs="">
	
	<cfif isObject(arguments.data)>
		<cfif listLast(getMetaData(arguments.data).name,".") eq "userBean">
		<cfset arguments.data=arguments.data.getAllValues()>
		<cfelse>
			<cfthrow type="custom" message="The attribute 'DATA' is not of type 'mura.user.userBean'">
		</cfif>
	</cfif>	
	
	<cfif not structKeyExists(arguments.data,"userID")>
		<cfthrow type="custom" message="The attribute 'USERID' is required when saving a user.">
	</cfif>
	
	<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#" name="rs">
	select userID from tusers where userID=<cfqueryparam value="#arguments.data.userID#">
	</cfquery>
	
	<cfif rs.recordcount>
		<cfreturn update(arguments.data,arguments.updateGroups,arguments.updateInterests, arguments.originID)>	
	<cfelse>
		<cfreturn create(arguments.data)>
	</cfif>

</cffunction>

<cffunction name="update" access="public" returntype="any" output="false">
	<cfargument name="data" type="any" default="#structnew()#"/>	
	<cfargument name="updateGroups" type="boolean" default="true" required="yes" />
	<cfargument name="updateInterests" type="boolean" default="true" required="yes" />
	<cfargument name="OriginID" type="string" default="" required="yes" />
	
	<cfset var error =""/>
	<cfset var addressBean =""/>
	<cfset var userBean="" />
	<cfset var pluginEvent = createObject("component","mura.event") />
			
	<cfif isObject(arguments.data)>
		<cfset arguments.data=arguments.data.getAllValues() />
	</cfif>
	
	<cfset pluginEvent.init(arguments.data)>
	<cfset pluginEvent.setValue("updateGroups",arguments.updateGroups) />
	<cfset pluginEvent.setValue("updateInterests",arguments.updateInterests) />
	<cfset pluginEvent.setValue("OriginID",arguments.OriginID) />
	
	<cfif not structKeyExists(arguments.data,"userID") or (structKeyExists(arguments.data,"userID") and not len(arguments.data.userID))>
		<cfreturn create(arguments.data) />
	</cfif>
	
	<cfif not structKeyExists(arguments.data,"siteID") or (structKeyExists(arguments.data,"siteID") and not len(arguments.data.siteID))>
		<cfthrow type="custom" message="The attribute 'SITEID' is required when saving a user.">
	</cfif>
	
	<cfset userBean=variables.userDAO.read(arguments.data.userid)/>
	
	<cfset userBean.set(arguments.data) />

	<!--- <cfif userBean.getType() eq 2 and  userBean.getAddressID() neq ''> --->
	<cfif userBean.getAddressID() neq ''>
	<cfset addressBean=variables.userDAO.readAddress(userBean.getAddressID()) />
	<cfset addressBean.set(arguments.data) />
	<cfset pluginEvent.setValue("addressBean",addressBean)/>	
	</cfif>
	
	<cfset pluginEvent.setValue("siteID", userBean.getSiteID())>
	
	<cfif userBean.getType() eq 1>	
		<cfset pluginEvent.setValue("groupBean",userBean)/>			
		<cfset variables.pluginManager.announceEvent("onBeforeGroupUpdate",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeGroupSave",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeGroup#userBean.getSubType()#Update",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeGroup#userBean.getSubType()#Save",pluginEvent)>		
	<cfelse>
		<cfset pluginEvent.setValue("userBean",userBean)/>	
		<cfset variables.pluginManager.announceEvent("onBeforeUserUpdate",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeUserSave",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeUser#userBean.getSubType()#Update",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeUser#userBean.getSubType()#Save",pluginEvent)>	
	</cfif>
	
	<cfif structIsEmpty(userBean.getErrors())>
	
		<cfif isDefined('arguments.data.activationNotify') and userBean.getInActive() eq 0>	
			<cfset variables.userUtility.sendActivationNotification(userBean) />
		</cfif>
		
		<cfif structKeyExists(arguments.data,"extendSetID") and len(arguments.data.extendSetID)>
			<cfset arguments.data.siteID=userBean.getSiteID() />
			<cfset variables.ClassExtensionManager.saveExtendedData(userBean.getUserID(),arguments.data,'tclassextenddatauseractivity')/>
		</cfif>
		
		<cfif structKeyExists(arguments.data,"newFile") and len(arguments.data.newfile)>
			<cfset setPhotoFile(userBean)/>
		</cfif>

		<cfif isDefined('arguments.data.removePhotoFile') and arguments.data.removePhotoFile eq "true" and len(userBean.getPhotoFileID())>
			<cfset variables.fileManager.deleteVersion(userBean.getPhotoFileID()) />
			<cfset userBean.setPhotoFileID("") />
		</cfif>
		
		<cfif userBean.getAddressID() neq ''>
		<cfset variables.userDAO.updateAddress(addressBean) />
		</cfif>
		
		<cfset variables.globalUtility.logEvent("UserID:#userBean.getUserID()# Type:#userBean.getType()# User:#userBean.getFName()# #userBean.getFName()# Group:#userBean.getGroupName()# was updated","mura-users","Information",true) />
		<cfset setLastUpdateInfo(userBean) />
		<cfset variables.userDAO.update(userBean,arguments.updateGroups,arguments.updateInterests,arguments.OriginID) />
		<cfset purgeUserCache(userBean=userBean)>
		<!--- Put in re-read the user to make sure that all extended attributes are cleaned. 
		Not need due to extended attributes now not using ext[pluginID] based form field names.
		<cfset userBean=read(userID=userBean.getUserID())>
		--->
		
		<cfif  userBean.getType() eq 1>	
			<cfset pluginEvent.setValue("groupBean",userBean)/>			
			<cfset variables.pluginManager.announceEvent("onGroupUpdate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onGroupSave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onGroup#userBean.getSubType()#Update",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onGroup#userBean.getSubType()#Save",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterGroupUpdate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterGroupSave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterGroup#userBean.getSubType()#Update",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterGroup#userBean.getSubType()#Save",pluginEvent)>		
		<cfelse>
			<cfset pluginEvent.setValue("userBean",userBean)/>	
			<cfset variables.pluginManager.announceEvent("onUserUpdate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onUserSave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onUser#userBean.getSubType()#Update",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onUser#userBean.getSubType()#Save",pluginEvent)>	
			<cfset variables.pluginManager.announceEvent("onAfterUserUpdate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterUserSave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterUser#userBean.getSubType()#Update",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterUser#userBean.getSubType()#Save",pluginEvent)>			
		</cfif>
		
	</cfif>
	
	<cfreturn userBean />
</cffunction>

<cffunction name="create" access="public" returntype="any" output="false">
	<cfargument name="data" type="any" default="#structnew()#"/>		
	
	<cfset var addressBean = "" />
	<cfset var userBean=application.serviceFactory.getBean("userBean") />
	<cfset var pluginEvent = createObject("component","mura.event") />
	
	<cfif isObject(arguments.data)>
		<cfset arguments.data=arguments.data.getAllValues() />
	</cfif>
	
	<cfset pluginEvent.init(arguments.data)>
	
	<cfset userBean.set(arguments.data) />
	
	<!--- MAKE SURE ALL REQUIRED DATA IS THERE--->
	<cfif not structKeyExists(arguments.data,"userID") or (structKeyExists(arguments.data,"userID") and not len(arguments.data.userID))>
		<cfset userBean.setUserID(createuuid()) />
	<cfelse>
		<cfset userBean.setUserID(arguments.data.userID) />
	</cfif>
	
	<cfif not structKeyExists(arguments.data,"siteID") or (structKeyExists(arguments.data,"siteID") and not len(arguments.data.siteID))>
		<cfthrow type="custom" message="The attribute 'SITEID' is required when saving a user.">
	</cfif>
	
	<cfif not structKeyExists(arguments.data,"fromMuraTrash")>
		<cfset addressBean=application.serviceFactory.getBean("addressBean") />
		<cfset addressBean.set(arguments.data) />
		<cfset addressBean.setAddressID(createuuid()) />
		<cfset addressBean.setUserID(userBean.getUserID()) />
		<cfset addressBean.setIsPrimary(1) />
		<cfset addressBean.setAddressName('Primary') />
	</cfif>
	
	<cfif userBean.getPassword() eq ''>
	<cfset userBean.setPassword(variables.userUtility.getRandomPassword(6,"Alpha","no"))/>
	</cfif>
	
	<cfset pluginEvent.setValue("siteID", userBean.getSiteID())>
	
	<cfif userBean.getType() eq 1>	
		<cfset pluginEvent.setValue("groupBean",userBean)/>			
		<cfset variables.pluginManager.announceEvent("onBeforeGroupCreate",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeGroupSave",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeGroup#userBean.getSubType()#Create",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeGroup#userBean.getSubType()#Save",pluginEvent)>				
	<cfelse>
		<cfset pluginEvent.setValue("userBean",userBean)/>	
		<cfset variables.pluginManager.announceEvent("onBeforeUserCreate",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeUserSave",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeUser#userBean.getSubType()#Create",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeUser#userBean.getSubType()#Save",pluginEvent)>		
	</cfif>
	
	<cfif structIsEmpty(userBean.getErrors())>
		
		<cfif structKeyExists(arguments.data,"extendSetID") and len(arguments.data.extendSetID)>
			<cfset arguments.data.siteID=userBean.getSiteID() />
			<cfset variables.ClassExtensionManager.saveExtendedData(userBean.getUserID(),arguments.data,'tclassextenddatauseractivity')/>
		</cfif>
		
		<cfif structKeyExists(arguments.data,"newFile") and len(arguments.data.newfile)>
			<cfset setPhotoFile(userBean)/>
		</cfif>
		
		<cfif structIsEmpty(userBean.getErrors())>
			<cfset variables.globalUtility.logEvent("UserID:#userBean.getUserID()# Type:#userBean.getType()# User:#userBean.getFName()# #userBean.getFName()# Group:#userBean.getGroupName()# was created","mura-users","Information",true) />
			<cfset setLastUpdateInfo(userBean) />
			<cfset variables.userDAO.create(userBean) />
			<cfset purgeUserCache(userBean=userBean)>
			<cfset variables.trashManager.takeOut(userBean)>
			<cfif isObject(addressBean)>
				<cfset variables.userDAO.createAddress(addressBean) />
			</cfif>
		</cfif>
		
		<cfset userBean.purgeExtendedData()>
		<cfset userBean.setIsNew(0)>
		
		<cfif  userBean.getType() eq 1>	
			<cfset pluginEvent.setValue("groupBean",userBean)/>			
			<cfset variables.pluginManager.announceEvent("onGroupCreate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onGroupSave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onGroup#userBean.getSubType()#Create",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onGroup#userBean.getSubType()#Save",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterGroupCreate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterGroupSave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterGroup#userBean.getSubType()#Create",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterGroup#userBean.getSubType()#Save",pluginEvent)>		
		<cfelse>
			<cfset pluginEvent.setValue("userBean",userBean)/>	
			<cfset variables.pluginManager.announceEvent("onUserCreate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onUserSave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onUser#userBean.getSubType()#Create",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onUser#userBean.getSubType()#Save",pluginEvent)>		
			<cfset variables.pluginManager.announceEvent("onAfterUserCreate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterUserSave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterUser#userBean.getSubType()#Create",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterUser#userBean.getSubType()#Save",pluginEvent)>	
		</cfif>
	</cfif>
	
	<cfreturn userBean />
</cffunction>

<cffunction name="delete" access="public" returntype="void" output="false">
	<cfargument name="userid" type="string" default=""/>
	<cfargument name="type" type="numeric" default="2"/>
	
	<cfset var userBean=read(arguments.userid) />
	<cfset var pluginEvent = createObject("component","mura.event").init(arguments) />
	<cfset var addresses="">
	<cfset pluginEvent.setValue("siteID", userBean.getSiteID())>
	
	<cfif  userBean.getType() eq 1>	
		<cfset pluginEvent.setValue("groupBean",userBean)/>			
		<cfset variables.pluginManager.announceEvent("onGroupDelete",pluginEvent)>	
		<cfset variables.pluginManager.announceEvent("onBeforeGroupDelete",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeGroup#userBean.getSubType()#Delete",pluginEvent)>				
	<cfelse>
		<cfset pluginEvent.setValue("userBean",userBean)/>	
		<cfset variables.pluginManager.announceEvent("onUserDelete",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeUserDelete",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeUser#userBean.getSubType()#Delete",pluginEvent)>		
	</cfif>
	
	<cfset variables.trashManager.throwIn(userBean)>
	<cfset variables.globalUtility.logEvent("UserID:#arguments.userid# Type:#userBean.getType()# User:#userBean.getFName()# #userBean.getFName()# Group:#userBean.getGroupName()# was deleted","mura-users","Information",true) />
	<cfif len(userBean.getPhotoFileID())>
		<cfset variables.fileManager.deleteVersion(userBean.getPhotoFileID()) />
	</cfif>
	
	<cfset variables.userDAO.delete(arguments.userid,arguments.type) />
	<cfset purgeUserCache(userBean=userBean)>
	
	<cfif  userBean.getType() eq 1>			
		<cfset variables.pluginManager.announceEvent("onAfterGroupDelete",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onAfterGroup#userBean.getSubType()#Delete",pluginEvent)>				
	<cfelse>
		<cfset variables.pluginManager.announceEvent("onAfterUserDelete",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onAfterUser#userBean.getSubType()#Delete",pluginEvent)>		
	</cfif>
	
</cffunction>

<cffunction name="readGroupMemberships" access="public" returntype="any" output="false">
	<cfargument name="userid" type="string" default="" required="yes"/>		
	<cfreturn variables.userDAO.readGroupMemberships(arguments.userid) />
</cffunction>

<cffunction name="getAddresses" access="public" returntype="any" output="false">
	<cfargument name="userid" type="string" default="" required="yes"/>		
	<cfreturn variables.userDAO.getAddresses(arguments.userid) />
</cffunction> 

<cffunction name="getAddressByID" access="public" returntype="any" output="false">
	<cfargument name="addressid" type="string" default="" required="yes"/>		
	<cfreturn variables.userDAO.getAddressByID(arguments.addressid) />
</cffunction> 

<cffunction name="readInterestGroups" access="public" returntype="any" output="false">
	<cfargument name="userid" type="string" default="" required="yes"/>		
	<cfreturn variables.userDAO.readInterestGroups(arguments.userid) />
</cffunction>

<cffunction name="readMemberships" access="public" returntype="any" output="false">
	<cfargument name="userid" type="string" default="" required="yes"/>		
	<cfreturn variables.userDAO.readMemberships(arguments.userid) />
</cffunction>

<cffunction name="getPublicGroups" access="public" returntype="any" output="false">
	<cfargument name="siteid" type="string" default="" required="yes"/>		
	<cfreturn variables.userGateway.getPublicGroups(arguments.siteid) />
</cffunction>

<cffunction name="getPublicGroupsIterator" access="public" returntype="any" output="false">
	<cfargument name="siteid" type="string" default="" required="yes"/>		
	<cfset var rs=variables.userGateway.getPublicGroups(arguments.siteid) />
	<cfset var it=getServiceFactory().getBean("userIterator")>
	<cfset it.setQuery(rs)>
	<cfreturn it>
</cffunction>

<cffunction name="getPrivateGroups" access="public" returntype="any" output="false">
	<cfargument name="siteid" type="string" default="" required="yes"/>	
	<cfreturn variables.userGateway.getPrivateGroups(arguments.siteid) />
</cffunction>

<cffunction name="getPrivateGroupsIterator" access="public" returntype="any" output="false">
	<cfargument name="siteid" type="string" default="" required="yes"/>	
	<cfset var rs=variables.userGateway.getPrivateGroups(arguments.siteid) />
	<cfset var it=getServiceFactory().getBean("userIterator")>
	<cfset it.setQuery(rs)>
	<cfreturn it>
</cffunction>

<cffunction name="createUserInGroup" access="public" returntype="void" output="false">
	<cfargument name="userid" type="string" default="" required="yes"/>		
	<cfargument name="groupid" type="string" default="" required="yes"/>
	<cfset variables.userDAO.createUserInGroup(arguments.userid,arguments.groupid) />
	<cfset purgeUserCache(userID=arguments.userID)>
	<cfset purgeUserCache(userID=arguments.groupID)>
</cffunction>

<cffunction name="deleteUserFromGroup" access="public" returntype="void" output="false">
	<cfargument name="userid" type="string" default="" required="yes"/>		
	<cfargument name="groupid" type="string" default="" required="yes"/>
	<cfset variables.userDAO.deleteUserFromGroup(arguments.userid,arguments.groupid) />
	<cfset purgeUserCache(userID=arguments.userID)>
	<cfset purgeUserCache(userID=arguments.groupID)>
</cffunction>

<cffunction name="getSearch" access="public" returntype="query" output="false">
	<cfargument name="search" type="string" default="" required="yes"/>		
	<cfargument name="siteid" type="string" default="" required="yes"/>
	<cfargument name="isPublic" type="numeric" default="1" required="yes"/>
	<cfreturn variables.userGateway.getSearch(arguments.search,arguments.siteid,arguments.isPublic) />
</cffunction>

<cffunction name="getAdvancedSearch" access="public" returntype="query" output="false">
	<cfargument name="data" type="any" default="" hint="This can be a struct or an instance of userFeedBean."/>	
	<cfargument name="siteid" type="any" hint="deprecated, use userFeedBean.setSiteID()" default=""/>
	<cfargument name="isPublic" type="any" hint="deprecated, use userFeedBean.setIsPublic()" default=""/>
	<cfreturn variables.userGateway.getAdvancedSearch(arguments.data,arguments.siteid,arguments.isPublic) />
</cffunction>

<cffunction name="getAdvancedSearchQuery" access="public" returntype="query" output="false">
	<cfargument name="userFeedBean" type="any" default="" required="yes"/>		
	
	<cfreturn getAdvancedSearch(arguments.userFeedBean) />
</cffunction>

<cffunction name="getAdvancedSearchIterator" access="public" returntype="query" output="false">
	<cfargument name="userFeedBean" type="any" required="yes"/>		
	<cfset var rs= getAdvancedSearch(arguments.userFeedBean) />
	<cfset var it = getServiceFactory().getBean("userIterator")>
	<cfset it.setQuery(rs)>
	<cfreturn it>
</cffunction>

<cffunction name="setLastUpdateInfo" access="public" returntype="void" output="false">
	<cfargument name="userBean" type="any" default="" required="yes"/>		
	<cfif session.mura.isLoggedIn>
			<cfset arguments.userBean.setLastUpdateBy(left(session.mura.fname & " " & session.mura.lname,50))/>
			<cfset arguments.userBean.setLastUpdateByID(session.mura.userID)/>
		<cfelse>
			<cfset arguments.userBean.setLastUpdateBy(left("#arguments.userBean.getFname()# #arguments.userBean.getlname()#",50))/>
			<cfset arguments.userBean.setLastUpdateByID(arguments.userBean.getUserID())/>
		</cfif>
</cffunction>

<cffunction name="sendLoginByEmail" access="public" returntype="string" output="false">
		<cfargument name="email" type="string" default=""/>
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="returnURL" type="string" default=""/>
	
		<cfreturn variables.userUtility.sendLoginByEmail(arguments.email,arguments.siteid,arguments.returnURL) />
		
</cffunction>

<cffunction name="sendLoginByUser" access="public" returntype="string" output="false">
		<cfargument name="userBean" type="any"/>
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="returnURL" type="string" default=""/>
		<cfargument name="isPublicReg" required="yes" type="boolean" default="false"/>
	
		<cfreturn variables.userUtility.sendLoginByUser(arguments.userBean,arguments.siteid,arguments.returnURL,arguments.isPublicReg) />
		
</cffunction>

<cffunction name="createAddress" access="public" returntype="struct" output="false">
	<cfargument name="data" type="any" default="#structnew()#"/>		
	
	<cfset var addressBean=application.serviceFactory.getBean("addressBean") />
	<cfset var userBean="" />
	
	<cfif isObject(arguments.data)>
		<cfset arguments.data=arguments.data.getAllValues() />
	</cfif>
	
	<cfif not structKeyExists(arguments.data,"userID") or (structKeyExists(arguments.data,"userID") and not len(arguments.data.userID))>
		<cfthrow type="custom" message="The attribute 'USERID' is required when saving an address.">
	</cfif>
	
	<cfset addressBean.set(arguments.data) />
	
	<cfset userBean=read(addressBean.getUserID())>
	<cfset addressBean.setSiteID(userBean.getSiteID())>
	
	<cfif not structKeyExists(arguments.data,"addressID") or (structKeyExists(arguments.data,"addressID") and not len(arguments.data.addressID))>
		<cfset addressBean.setAddressID(createuuid()) />
	<cfelse>
		<cfset addressBean.setAddressID(arguments.data.addressID) />
	</cfif>
	
	<cfif structIsEmpty(addressBean.getErrors())>
		<cfset variables.userDAO.createAddress(addressBean) />
		<cfif structKeyExists(arguments.data,"extendSetID")>
			<cfset arguments.data.siteID=addressBean.getSiteID() />
			<cfset variables.ClassExtensionManager.saveExtendedData(addressBean.getAddressID(),arguments.data,'tclassextenddatauseractivity')/>
		</cfif>
	</cfif>
	<cfset variables.trashManager.takeOut(addressBean)>
	<cfset purgeUserCache(userBean=userBean)>
	<cfreturn addressBean />
</cffunction>

<cffunction name="updateAddress" access="public" returntype="any" output="false">
	<cfargument name="data" type="any" default="#structnew()#"/>	
	
	<cfset var error =""/>
	<cfset var addressBean=""/>
	<cfset var userBean="" />
	
	<cfif isObject(arguments.data)>
		<cfset addressBean=arguments.data>
		<cfset arguments.data=arguments.data.getAllValues() />
	<cfelseif structKeyExists(arguments.data,"addressID")>
		<cfset addressBean=variables.userDAO.readAddress(arguments.data.addressid)>
	<cfelse>
		<cfset addressBean=getBean("addressBean")>
	</cfif>
	
	<cfif not structKeyExists(arguments.data,"userID") or (structKeyExists(arguments.data,"userID") and not len(arguments.data.userID))>
		<cfthrow type="custom" message="The attribute 'USERID' is required when saving an address.">
	</cfif>
	
	<cfif not structKeyExists(arguments.data,"addressID") or (structKeyExists(arguments.data,"addressID") and not len(arguments.data.addressID))>
		<cfreturn createAddress(arguments.data) />
	</cfif>
	
	<cfset addressBean.set(arguments.data) />
	
	<cfset userBean=read(addressBean.getUserID())>
	<cfset addressBean.setSiteID(userBean.getSiteID())>
	
	<cfif structIsEmpty(addressBean.getErrors())>
		<cfset variables.userDAO.updateAddress(addressBean) />
		<cfif structKeyExists(arguments.data,"extendSetID")>
			<cfset arguments.data.siteID=addressBean.getSiteID() />
			<cfset variables.ClassExtensionManager.saveExtendedData(addressBean.getAddressID(),arguments.data,'tclassextenddatauseractivity')/>
		</cfif>
	</cfif>
	
	<cfset purgeUserCache(userBean=userBean)>
	
	<cfreturn addressBean />
</cffunction>

<cffunction name="deleteAddress" access="public" returntype="void" output="false">
	<cfargument name="addressid" type="string" default=""/>			
	<cfset var addressBean=variables.userDAO.readAddress(arguments.addressID) />
	<cfif not addressBean.getIsNew()>
		<cfset variables.trashManager.throwIn(addressBean)>
		<cfset variables.userDAO.deleteAddress(arguments.addressid) />
	</cfif>
	<cfset purgeUserCache(userID=addressBean.getUserID())>
	
</cffunction>

<cffunction name="getCurrentUserID" access="public" returntype="string" output="false">		
	
	<cfreturn session.mura.userID />
	
</cffunction>

<cffunction name="getCurrentName" access="public" returntype="string" output="false">		
	
	<cftry>
		<cfreturn session.mura.fname & " " & session.mura.lname />
		<cfcatch>
			<cfreturn ''/>
		</cfcatch>
	</cftry>
	
</cffunction>

<cffunction name="getCurrentLastLogin" access="public" returntype="string" output="false">		
	
	<cftry>
		<cfreturn session.mura.lastlogin />
		<cfcatch>
			<cfreturn ''/>
		</cfcatch>
	</cftry>
	
</cffunction>

<cffunction name="getCurrentCompany" access="public" returntype="string" output="false">		
	
	<cftry>
		<cfreturn session.mura.company />
		<cfcatch>
			<cfreturn ''/>
		</cfcatch>
	</cftry>
	
</cffunction>

<cffunction name="setPhotoFile" output="false">
<cfargument name="userBean" />

<cfset var theFileStruct=structNew() />
<cfset var error=structNew() />
<cfset var tempFile=structNew()>

<!--- Check to see if it's a posted binary file--->
<cfif variables.fileManager.isPostedFile(userBean.getNewFile())>
	<cffile action="upload" result="tempFile" filefield="NewFile" nameconflict="makeunique" destination="#variables.configBean.getTempDir()#">
<!--- Else fake it to think it was a posted files--->
<cfelse>
	<cfset tempFile=variables.fileManager.emulateUpload(userBean.getNewFile())>
</cfif>

<cfif (tempFile.ServerFileExt eq "jpg" or tempFile.ServerFileExt eq "gif" or tempFile.ServerFileExt eq "png") and tempFile.ContentType eq "Image">
	<cftry>
		<cfif len(arguments.userBean.getPhotoFileID())>
			<cfset variables.fileManager.deleteVersion(arguments.userBean.getPhotoFileID()) />
		</cfif>
		<cfset theFileStruct=variables.fileManager.process(tempFile,arguments.userBean.getSiteID()) />
		<cfset arguments.userBean.setPhotoFileID(variables.fileManager.create(theFileStruct.fileObj,arguments.userBean.getUserID(),arguments.userBean.getSiteID(),tempFile.ClientFile,tempFile.ContentType,tempFile.ContentSubType,tempFile.FileSize,'00000000000000000000000000000000008',tempFile.ServerFileExt,theFileStruct.fileObjSmall,theFileStruct.fileObjMedium)) />
		<cfcatch>
			<cfset error.photo="The file you uploaded appears to be corrupt. Please select another file to upload."/>
			<cfset userBean.setErrors(error)/> 
		</cfcatch>
	</cftry>
<cfelse>
	<cffile action="delete" file="#variables.configBean.getTempDir()##tempFile.serverfile#">
	<cfset error.photo="The file you uploaded is not a supported format. Only, JPEG, GIF and PNG files are accepted."/>
	<cfset userBean.setErrors(error)/> 
</cfif>
</cffunction>

<cffunction name="setUserBeanMetaData" output="false" returntype="any">
	<cfargument name="userBean">
	<cfreturn variables.userDAO.setUserBeanMetaData(userBean)>
</cffunction>

<cffunction name="setUserStructDefaults" output="false" access="public" returntype="void">
<cfset var user="">
<cfif not structKeyExists(session,"mura")>
	<cfif yesNoFormat(variables.configBean.getValue("useLegacySessions")) 
			and len(getAuthUser()) and isValid("UUID",listFirst(getAuthUser(),"^"))>
		<cfset user=read(listFirst(getAuthUser(),"^"))>
		<cfset variables.userUtility.setUserStruct(user.getAllValues())>
	<cfelse>
		<cfset variables.userUtility.setUserStruct()>
	</cfif>
</cfif>
</cffunction>

<cffunction name="getIterator" returntype="any" output="false">
	<cfreturn getServiceFactory().getBean("userIterator").init()>
</cffunction>

<cffunction name="getBean" returntype="any" output="false">
	<cfreturn variables.userDAO.getBean()>
</cffunction>

<cffunction name="getUserFeedBean" returntype="any" output="false">
	<cfset var userFeedBean=createObject("component","mura.user.userFeedBean").init()>
	<cfset userFeedBean.setUserManager(this)>
	<cfreturn userFeedBean>
</cffunction>

</cfcomponent>