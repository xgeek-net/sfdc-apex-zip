# SFDC APEX Zip Attachments With JSZip
@see https://www.xgeek.net/salesforce/apex/salesforce-apex-zip-attachments-with-jszip/

<a href="https://githubsfdeploy.herokuapp.com?owner=xgeek-net&repo=sfdc-apex-zip">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## Usage

### VF Page
To include javascript in your VF Page.

```html
<apex:includeScript value="/soap/ajax/25.0/connection.js"/>
<apex:includeScript value="/soap/ajax/25.0/apex.js"/>
<apex:includeScript value="{!URLFOR($Resource.jQuery)}"/>
<apex:includeScript value="{!URLFOR($Resource.JSZip)}"/>
```
### Javascript
Request Attachments file Blob data from WebService with Attachment Ids.

```java
var rIds = '00P1000000MUdY2,00P1000000MUdXi';	//Attachment Ids
sforce.connection.sessionId = '{!$Api.Session_ID}';
var response = sforce.apex.execute("WS_ZipUtil","getAttachmentById",{sfdcId:rIds});
var respObj = JSON.parse( response  );
if( respObj['status'] != '200' ) {
	alert( respObj ['error'] );
	return;
}
var fileData = respObj['data'];
```
With Parent Object Id

```java
var rId = '0011000000uzA9u';	//Object Id
sforce.connection.sessionId = '{!$Api.Session_ID}';
var response = sforce.apex.execute("WS_ZipUtil","getAttachmentByParentId",{sfdcId:rId});
var respObj = JSON.parse( response  );
if( respObj['status'] != '200' ) {
	alert( respObj ['error'] );
	return;
}
var fileData = respObj['data'];
```

With Pages Url

```java
var fileUrl = '/apex/Demo_WS_ZipUtil,/apex/AccountSitePage';	//File url
sforce.connection.sessionId = '{!$Api.Session_ID}';
var response = sforce.apex.execute("WS_ZipUtil","getPagePdfBlobByUrl",{pageUrl:fileUrl});
var respObj = JSON.parse( response  );
if( respObj['status'] != '200' ) {
	alert( respObj ['error'] );
	return;
}
var fileData = respObj['data'];
```
