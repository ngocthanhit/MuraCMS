<cfcomponent extends="controller" output="false">

<cffunction name="setContentManager" output="false">
	<cfargument name="contentManager">
	<cfset variables.contentManager=arguments.contentManager>
</cffunction>

<cffunction name="setContentUtility" output="false">
	<cfargument name="contentUtility">
	<cfset variables.contentUtility=arguments.contentUtility>
</cffunction>

<cffunction name="setContentGateway" output="false">
	<cfargument name="contentGateway">
	<cfset variables.contentGateway=arguments.contentGateway>
</cffunction>

<cffunction name="before" output="false">
	<cfargument name="rc">
	
	<cfif not variables.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid)>
		<cfset secure(arguments.rc)>
	</cfif>

	<cfparam name="arguments.rc.return" default=""/>
	<cfparam name="arguments.rc.startrow" default="1"/>
	<cfparam name="arguments.rc.contentHistID" default="#createuuid()#"/>
	<cfparam name="arguments.rc.notify" default=""/>
	<cfparam name="arguments.rc.preview" default="0"/>
	<cfparam name="arguments.rc.size" default="20"/>
	<cfparam name="arguments.rc.isNav" default="0"/>
	<cfparam name="arguments.rc.isLocked" default="0"/>
	<cfparam name="arguments.rc.forceSSL" default="0"/>
	<cfparam name="arguments.rc.target" default="_self"/>
	<cfparam name="arguments.rc.searchExclude" default="0"/>
	<cfparam name="arguments.rc.restricted" default="0"/>
	<cfparam name="arguments.rc.relatedcontentid" default=""/>
	<cfparam name="arguments.rc.responseChart" default="0"/>
	<cfparam name="arguments.rc.displayTitle" default="0"/>
	<cfparam name="arguments.rc.closeCompactDisplay" default=""/>
	<cfparam name="arguments.rc.compactDisplay" default=""/>
	<cfparam name="arguments.rc.doCache" default="1"/>
	<cfparam name="arguments.rc.returnURL" default=""/>
	<cfparam name="arguments.rc.homeID" default=""/>
	<cfparam name="arguments.rc.datasource" default="#variables.configBean.getDatasource()#"/>
	<cfparam name="arguments.rc.parentid" default=""/>
	<cfparam name="arguments.rc.menuTitle" default=""/>
	<cfparam name="arguments.rc.title" default=""/>
	<cfparam name="arguments.rc.action" default=""/>
	<cfparam name="arguments.rc.ptype" default="Page"/>
	<cfparam name="arguments.rc.contentid" default=""/>
	<cfparam name="arguments.rc.contenthistid" default=""/>
	<cfparam name="arguments.rc.type" default="Page"/>
	<cfparam name="arguments.rc.body" default=""/>
	<cfparam name="arguments.rc.oldbody" default=""/>
	<cfparam name="arguments.rc.oldfilename" default=""/>
	<cfparam name="arguments.rc.url" default=""/>
	<cfparam name="arguments.rc.filename" default=""/>
	<cfparam name="arguments.rc.metadesc" default=""/>
	<cfparam name="arguments.rc.metakeywords" default=""/>
	<cfparam name="arguments.rc.orderno" default="0"/>
	<cfparam name="arguments.rc.display" default="0"/>
	<cfparam name="arguments.rc.displaystart" default=""/>
	<cfparam name="arguments.rc.displaystop" default=""/>
	<cfparam name="arguments.rc.abstract" default=""/>
	<cfparam name="arguments.rc.frameid" default="0"/>
	<cfparam name="arguments.rc.abstract" default=""/>
	<cfparam name="arguments.rc.editor" default="0"/>
	<cfparam name="arguments.rc.author" default="0"/>
	<cfparam name="arguments.rc.moduleid" default="00000000000000000000000000000000000"/>
	<cfparam name="arguments.rc.objectid" default=""/>
	<cfparam name="arguments.rc.lastupdate" default=""/>
	<cfparam name="arguments.rc.siteid" default=""/>
	<cfparam name="arguments.rc.title" default=""/>
	<cfparam name="arguments.rc.topid" default="00000000000000000000000000000000001"/>
	<cfparam name="arguments.rc.startrow" default="1"/>
	<cfparam name="arguments.rc.lastupdate" default="#now()#"/>
	<cfparam name="session.viewDepth" default="#variables.settingsManager.getSite(arguments.rc.siteid).getviewdepth()#"/>
	<cfparam name="session.nextN" default="#variables.settingsManager.getSite(arguments.rc.siteid).getnextN()#"/>
	<cfparam name="session.keywords" default=""/>
	<cfparam name="arguments.rc.startrow" default="1"/>
	<cfparam name="arguments.rc.date1" default=""/>
	<cfparam name="arguments.rc.date2" default=""/>
	<cfparam name="arguments.rc.return" default=""/>
	<cfparam name="arguments.rc.forceSSL" default="0"/>
	<cfparam name="arguments.rc.closeCompactDisplay" default=""/>
	<cfparam name="arguments.rc.returnURL" default=""/>
	<cfparam name="arguments.rc.locking" default="false"/>
	

	
</cffunction>

<cffunction name="list" output="false">
	<cfargument name="rc">

	<cfset arguments.rc.rsTop=variables.contentManager.getlist(arguments.rc) />
	
	<cfif arguments.rc.moduleid neq '00000000000000000000000000000000000'>
		<cfset arguments.rc.nextN=variables.utility.getNextN(arguments.rc.rsTop,30,arguments.rc.startrow)/>
	</cfif>
	
</cffunction>

<cffunction name="loadsitemanager" output="false">
	<cfargument name="rc">

	<cfset arguments.rc.rsTop=variables.contentManager.getlist(arguments.rc) />
	
	<cfif arguments.rc.moduleid neq '00000000000000000000000000000000000'>
		<cfset arguments.rc.nextN=variables.utility.getNextN(arguments.rc.rsTop,30,arguments.rc.startrow)/>
	</cfif>

</cffunction>

<cffunction name="draft" output="false">
	<cfargument name="rc">
	
	<cfset arguments.rc.rsList=variables.contentManager.getDraftList(arguments.rc.siteid) />
	
</cffunction>

<cffunction name="edit" output="false">
	<cfargument name="rc">

	<cfset var local=structNew()>
	
	<cfset local.currentBean=getBean("content").loadBy(contentID=arguments.rc.contentID, siteID= arguments.rc.siteid)> 
	
  	<cfif local.currentBean.getIsNew()>
		<cfset arguments.rc.crumbdata=variables.contentManager.getCrumbList(arguments.rc.parentid,arguments.rc.siteid)/>
	 <cfelse>
		<cfset arguments.rc.crumbdata=variables.contentManager.getCrumbList(arguments.rc.contentID,arguments.rc.siteid)/>
	</cfif>

   <cfset arguments.rc.contentBean=variables.contentManager.getcontentVersion(arguments.rc.contenthistid,arguments.rc.siteid)/>
  
   <cfif arguments.rc.contentid neq '' and arguments.rc.contenthistid neq '' and arguments.rc.contentBean.getIsNew() eq 1>
		<cfset variables.fw.redirect(action="cArch.hist",append="contentid,siteid,startrow,moduleid,parentid,type",path="")>
   </cfif>
   
  	<cfset arguments.rc.rsCount=variables.contentManager.getItemCount(arguments.rc.contentid,arguments.rc.siteid) />
  	<cfset arguments.rc.rsPageCount=variables.contentManager.getPageCount(arguments.rc.siteid) />
  	<cfset arguments.rc.rsRestrictGroups=variables.contentUtility.getRestrictGroups(arguments.rc.siteid) />
  	<cfset arguments.rc.rsTemplates=variables.contentUtility.getTemplates(arguments.rc.siteid,arguments.rc.type) />
  	<cfset arguments.rc.rsCategoryAssign=variables.contentManager.getCategoriesByHistID(arguments.rc.contenthistID) />
	<cfif arguments.rc.moduleID eq '00000000000000000000000000000000000'>
		  <cfset variables.contentManager.setRequestRegionObjects(arguments.rc.contenthistid,arguments.rc.siteid) />
	</cfif>
	<cfset arguments.rc.rsRelatedContent=variables.contentManager.getRelatedContent(arguments.rc.siteid, arguments.rc.contenthistID) />
	
</cffunction>

<cffunction name="update" ouput="false">
	<cfargument name="rc">
	<cfset var local=structNew()>
	 
	<cfif not isNumeric(arguments.rc.orderno)>
		<cfset arguments.rc.orderno=0>
	</cfif>
	
	<cfset arguments.rc.crumbData=variables.contentGateway.getCrumblist(arguments.rc.contentID, arguments.rc.siteid) /> 
	
	<cfset local.currentBean=getBean("content").loadBy(contentID=arguments.rc.contentID, siteID= arguments.rc.siteid)> 
	
	 <cfif not local.currentBean.getIsNew()>
		 <cfset arguments.rc.crumbData=variables.contentGateway.getCrumblist(arguments.rc.contentID, arguments.rc.siteid) />
		 <cfset arguments.rc.perm=variables.permUtility.getNodePerm(arguments.rc.crumbData) />  
	 </cfif>
	 
	 <cfif local.currentBean.getIsNew() and len(arguments.rc.parentID)>
		<cfset arguments.rc.crumbData=variables.contentGateway.getCrumblist(arguments.rc.parentID, arguments.rc.siteid) />
		<cfset arguments.rc.perm=variables.permUtility.getNodePerm(arguments.rc.crumbData) />  
	 </cfif>
	 
	<cfset  arguments.rc.allowAction=listFindNoCase('author,editor',arguments.rc.perm) />
	 
	 <cfif arguments.rc.allowAction and arguments.rc.action eq 'deleteall'>
		<cfset arguments.rc.topid=variables.contentManager.deleteAll(arguments.rc) />  
	 </cfif>
  
	 <cfif arguments.rc.allowAction and arguments.rc.action eq 'deletehistall'>
	 	<cfset variables.contentManager.deletehistAll(arguments.rc) />
	 </cfif>
  
	 <cfif arguments.rc.allowAction and arguments.rc.action eq 'delete'>
		<cfset variables.contentManager.delete(arguments.rc) />
	 </cfif>
  
	 <cfif arguments.rc.allowAction and arguments.rc.action eq 'add'>
		<cfif structKeyExists(arguments.rc,"preserveID") and isValid('UUID',arguments.rc.preserveID)>
			 <cfset arguments.rc.contentBean=getBean('content').loadBy(contentHistID=arguments.rc.preserveID, siteid=arguments.rc.siteid).set(arguments.rc).save() />
		<cfelse>
			 <cfset arguments.rc.contentBean=getBean('content').loadBy(contentID=arguments.rc.contentID, siteid=arguments.rc.siteid).set(arguments.rc).save() />
		</cfif>
	 </cfif>
	 
	 <cfif arguments.rc.allowAction and arguments.rc.action eq 'multiFileUpload'>
		  <cfset variables.contentManager.multiFileUpload(arguments.rc) />
	 </cfif>
	 
	  <cfif arguments.rc.allowAction and arguments.rc.action eq 'add' and arguments.rc.contentID neq '00000000000000000000000000000000001'>
	      <cfset arguments.rc.topid=rc.contentBean.getParentID() />	
	  </cfif>
	 
	<cfif arguments.rc.closeCompactDisplay neq 'true' and arguments.rc.action neq 'multiFileUpload'>
		
			<cfif len(arguments.rc.returnURL) and (arguments.rc.action eq 'delete' or arguments.rc.action eq 'deletehistall' or arguments.rc.preview eq 0)>
					<cflocation url="#rc.returnURL#" addtoken="false"/>
			</cfif>
			
			<cfif arguments.rc.action eq 'delete' or arguments.rc.action eq 'deletehistall' or (arguments.rc.return eq 'hist' and arguments.rc.preview eq 0)>
				<cfset variables.fw.redirect(action="cArch.hist",append="contentid,siteid,startrow,moduleid,parentid,type,compactDisplay",path="")>
			</cfif>
			
			<cfif arguments.rc.return eq 'changesets' and len(rc.contentBean.getChangesetID())>
				<cfset variables.fw.redirect(action="cChangesets.assignments",append="changesetID,siteid",path="")>
			</cfif>
			
			<cfif arguments.rc.preview eq 0>
				<cfset variables.fw.redirect(action="cArch.list",append="topid,siteid,startrow,moduleid",path="")>
			<cfelse>
				<cfset arguments.rc.parentid=rc.contentBean.getParentID()>
				<cfset arguments.rc.type=rc.contentBean.getType()>
				<cfset arguments.rc.contentid=rc.contentBean.getContentID()>
				<cfset arguments.rc.contenthistid=rc.contentBean.getContentHistID()>
				<cfset arguments.rc.preview=1>
				<cfset variables.fw.redirect(action="cArch.edit",append="contenthistid,contentid,type,parentid,topid,siteid,moduleid,preview,startrow,return",path="")>
			</cfif>
	</cfif>

</cffunction>

<cffunction name="hist" ouput="false">
	<cfargument name="rc">
	<cfset arguments.rc.rshist=variables.contentManager.getHist(arguments.rc.contentid,arguments.rc.siteid) />
	<cfset arguments.rc.contentBean=variables.contentManager.getActiveContent(arguments.rc.contentid,arguments.rc.siteid) />
	<cfset arguments.rc.rsCount=variables.contentManager.getItemCount(arguments.rc.contentid,arguments.rc.siteid) />
</cffunction>

<cffunction name="datamanager" ouput="false">
	<cfargument name="rc">
	<cfset arguments.rc.crumbData=variables.contentManager.getCrumbList(arguments.rc.contentid,arguments.rc.siteid) />
	<cfset arguments.rc.contentBean=variables.contentManager.getActiveContent(arguments.rc.contentid,arguments.rc.siteid) />
</cffunction>

<cffunction name="downloaddata" ouput="false">
	<cfargument name="rc">
	<cfset arguments.rc.contentBean=variables.contentManager.getActiveContent(arguments.rc.contentid,arguments.rc.siteid) />
	<cfset arguments.rc.datainfo=variables.contentManager.getDownloadselect(arguments.rc.contentid,arguments.rc.siteid) />
</cffunction>

<cffunction name="search" ouput="false">
	<cfargument name="rc">
	<cfset arguments.rc.rslist=variables.contentManager.getPrivateSearch(arguments.rc.siteid,arguments.rc.keywords) />
	<cfset session.keywords=rc.keywords/>
	<cfset arguments.rc.nextn=variables.utility.getNextN(arguments.rc.rsList,30,arguments.rc.startrow) />
</cffunction>

<cffunction name="loadNotify" ouput="false">
	<cfargument name="rc">
	<cfif arguments.rc.contentid eq ''>
		<cfset arguments.rc.crumbData=variables.contentManager.getCrumbList(arguments.rc.parentid,arguments.rc.siteid) />
	<cfelse>
		<cfset arguments.rc.crumbData=variables.contentManager.getCrumbList(arguments.rc.contentid,arguments.rc.siteid) />
	</cfif>
</cffunction>

<cffunction name="copy" ouput="false">
	<cfargument name="rc">
	<cfset variables.contentManager.copy(arguments.rc.siteid,arguments.rc.contentID,arguments.rc.parentID,arguments.rc.copyAll, true, true)  />
</cffunction>

<cffunction name="saveCopyInfo" ouput="false">
	<cfargument name="rc">
	<cfset variables.contentManager.saveCopyInfo(arguments.rc.siteid,arguments.rc.contentID,arguments.rc.copyAll)  />
</cffunction>

<cffunction name="multiFileUpload" ouput="false">
	<cfargument name="rc">

	<cfset arguments.rc.crumbdata=variables.contentManager.getCrumbList(arguments.rc.parentid,arguments.rc.siteid)>
  	<cfset arguments.rc.rsCount=variables.contentManager.getItemCount(arguments.rc.contentid,arguments.rc.siteid)>
  	<cfset arguments.rc.rsPageCount=variables.contentManager.getPageCount(arguments.rc.siteid)>
  	<cfset arguments.rc.rsRestrictGroups=variables.contentUtility.getRestrictGroups(arguments.rc.siteid)>
	
	
</cffunction>

</cfcomponent>