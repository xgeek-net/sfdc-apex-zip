/**
 * Copyright (c) 2012, Xgeek.net, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Xgeek.net, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * Zip WebService Class With JSZip
 * @see http://www.xgeek.net
 * 
 * Reference page ：
 *  http://andyinthecloud.com/category/zip/
 */
global class WS_ZipUtil {

    /**
     * Receive Attachments info from Attachment id list
     * Use "," split for multiple Attachments
     */
    webService static String getAttachmentById( String sfdcId ){

        if( String.isEmpty( sfdcId ) ) return WS_Util.errorJson('Parameter sfdcId is required.');
        
        List<String> sfdcIdList = sfdcId.split(',');
        List<Attachment> attachmentList =  [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id IN :sfdcIdList];
        if( attachmentList == null || attachmentList.size() == 0 ) return WS_Util.errorJson('Attachment not found.');

        return wrapAttachmentList( attachmentList );
    }

    /**
     * Receive Attachments info from Attachment ParentId
     */
    webService static String getAttachmentByParentId( String sfdcId ){

        if( String.isEmpty( sfdcId ) ) return WS_Util.errorJson('Parameter sfdcId is required.');
        
        List<Attachment> attachmentList =  [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId = :sfdcId];
        if( attachmentList == null || attachmentList.size() == 0 ) return WS_Util.errorJson('Attachment not found.');

        return wrapAttachmentList( attachmentList );
    }

    /**
     * Receive Page Blob as PDF from url
     * Use "," split for multiple pages
     */
    webService static String getPagePdfBlobByUrl( String pageUrl ){

        if( String.isEmpty( pageUrl ) ) return WS_Util.errorJson('Parameter pageUrl is required.');
        
        List<Object> dataList = new List<Object>();
        List<String> urlList = pageUrl.split(',');
        for( String url : urlList ){
            PageReference pagePdf = new PageReference( url );
            Blob pageBlob = pagePdf.getContentAsPDF();
            Map<String, String> pageMap = new Map<String, String>();
            pageMap.put( 'Name', getFileNameFromUrl( url ) + '.pdf' );
            pageMap.put( 'Body', EncodingUtil.base64Encode( pageBlob ) );
            dataList.add( pageMap );
        }
       
        return WS_Util.normalJson( dataList );
    }

    /**
     * Save Zip file to Document
     */
    webService static String saveToDocument( String zipFileData, String fileName ){

        try{
            String userId = UserInfo.getUserId();
            List<Document> docList = [SELECT Id, Name, FolderId, Body FROM Document WHERE Name = :fileName AND FolderId = :userId LIMIT 1 ];
            Document doc = new Document();
            if( docList == null || docList.size() == 0 ) {
                doc.Name = fileName;
                doc.FolderId = UserInfo.getUserId();
                doc.Body = EncodingUtil.base64Decode( zipFileData );
                insert doc;
            } else {
                doc = docList.get(0);
                doc.Body = EncodingUtil.base64Decode( zipFileData );
                update doc;
            }
            return WS_Util.normalJson( doc.Id );
        } catch ( Exception ex ) {
            return WS_Util.errorJson( ex.getMessage() );
        }
    }

    //Format JSON String from AttachmentList
    private static String wrapAttachmentList( List<Attachment> attachmentList ){

        List<Object> dataList = new List<Object>();
        for( Attachment at : attachmentList ){
            Map<String, String> atMap = new Map<String, String>();
            //atMap.put( 'Id', at.Id );
            atMap.put( 'Name', at.Name );
            atMap.put( 'Body', EncodingUtil.base64Encode( at.Body ) );
            //atMap.put( 'ContentType', at.ContentType );
            dataList.add( atMap );
        }
        return WS_Util.normalJson( dataList );
    }

    //Get file name from url
    private static String getFileNameFromUrl( String pageUrl ){
        List<String> urlArray = pageUrl.split('/');
        return urlArray.get( (urlArray.size() - 1) );
    }

}