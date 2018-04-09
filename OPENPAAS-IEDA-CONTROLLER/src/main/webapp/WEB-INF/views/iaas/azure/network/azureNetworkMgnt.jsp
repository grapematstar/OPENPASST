<%
/* =================================================================
 * 작성일 : 2018.04.00
 * 작성자 : 이정윤 
 * 상세설명 : Azure Network 관리 화면
 * =================================================================
 */ 
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix = "spring" uri = "http://www.springframework.org/tags" %>

<script>
var save_lock_msg = '<spring:message code="common.save.data.lock"/>';//등록 중 입니다.
var detail_rg_lock_msg='<spring:message code="common.search.detaildata.lock"/>';//상세 조회 중 입니다.
var text_required_msg='<spring:message code="common.text.vaildate.required.message"/>';//을(를) 입력하세요.
var delete_confirm_msg ='<spring:message code="common.popup.delete.message"/>';//삭제 하시겠습니까?
var delete_lock_msg= '<spring:message code="common.delete.data.lock"/>';//삭제 중 입니다.

var accountId ="";
var bDefaultAccount = "";


$(function() {
    
    bDefaultAccount = setDefaultIaasAccountList("azure");
    
    $('#azure_vnetGrid').w2grid({
        name: 'azure_vnetGrid',
        method: 'GET',
        msgAJAXerror : 'Azure 계정을 확인해주세요.',
        header: '<b>Network 목록</b>',
        multiSelect: false,
        show: {    
                selectColumn: true,
                footer: true},
        style: 'text-align: center',
        columns    : [
                     {field: 'recid',     caption: 'recid', hidden: true}
                   , {field: 'accountId',     caption: 'accountId', hidden: true}
                   , {field: 'networkName', caption: 'Network Name', size: '50%', style: 'text-align:center', render : function(record){
                       if(record.name == null || record.name == ""){
                           return "-"
                       }else{
                           return record.name;
                       }}
                   }
                   , {field: 'subscriptionName', caption: 'Subscription', size: '50%', style: 'text-align:center'}
                   , {field: 'azureSubscriptionId', caption: 'Subscription ID', size: '50%', style: 'text-align:center'}
                   , {field: 'resourceType', caption: 'Type', size: '50%', style: 'text-align:center'}
                   , {field: 'location', caption: 'Location', size: '50%', style: 'text-align:center'}
                   , {field: 'resourceGroupName', caption: 'Resource Group', size: '50%', style: 'text-align:center'}
                   , {field: 'dnsServer', caption: 'DNS Servers', size: '50%', style: 'text-align:center'}
                   , {field: 'networkAddressSpaceCidr', caption: 'Address Space', size: '50%', style: 'text-align:center'}
                   ],
        onSelect: function(event) {
            event.onComplete = function() {
                $('#deleteBtn').attr('disabled', false);
                var accountId =  w2ui.azure_vnetGrid.get(event.recid).accountId;
                var networkName = w2ui.azure_vnetGrid.get(event.recid).networkName;
                var location = w2ui.azure_vnetGrid.get(event.recid).location;
                //doSearchRgDetailInfo(accountId, networkName); 
                //doSearchRgResourceInfo(accountId, networkName); 
            }
        },
        onUnselect: function(event) {
            event.onComplete = function() {
                $('#deleteBtn').attr('disabled', true);
                w2ui['azure_deviceGrid'].clear();
            }
        },
           onLoad:function(event){
            if(event.xhr.status == 403){
                location.href = "/abuse";
                event.preventDefault();
            }
        }, onError:function(evnet){
        }
    });
    
    $('#azure_deviceGrid').w2grid({
        name: 'azure_deviceGrid',
        method: 'GET',
        msgAJAXerror : 'Azure 계정을 확인해주세요.',
        header: '<b>Resource 목록</b>',
        multiSelect: false,
        show: {    
                selectColumn: false,
                footer: true},
        style: 'text-align: center',
        columns    : [
                     {field: 'recid',     caption: 'recid', hidden: true}
                   , {field: 'accountId',     caption: 'accountId', hidden: true}
                   , {field: 'resourceName', caption: 'Resource Name', size: '50%', style: 'text-align:center'}
                   , {field: 'resourceType', caption: 'Resource Type', size: '50%', style: 'text-align:center'}
                   , {field: 'resourceLocation', caption: 'Location', size: '50%', style: 'text-align:center'}
                   ],
        onSelect: function(event) {
            event.onComplete = function() {
            }
        },
        onUnselect: function(event) {
            event.onComplete = function() {
            	
            }
        },
           onLoad:function(event){
            if(event.xhr.status == 403){
                location.href = "/abuse";
                event.preventDefault();
            }
        }, onError:function(evnet){
        }
    });
    
    /********************************************************
     * 설명 : Network 생성 버튼 클릭
    *********************************************************/
    $("#addBtn").click(function(){
        if($("#addBtn").attr('disabled') == "disabled") return;
       w2popup.open({
           title   : "<b>Azure Network 생성</b>",
           width   : 580,
           height  : 470,
           modal   : true,
           body    : $("#registPopupDiv").html(),
           buttons : $("#registPopupBtnDiv").html(),
           onOpen  : function () {
        	   setAzureRegion();
        	   setAzureSubscription();
           },
           onClose : function(event){
            accountId = $("select[name='accountId']").val();
            w2ui['azure_vnetGrid'].clear();
            w2ui['azure_deviceGrid'].clear();
            doSearch();
            $("#rgDetailTable td").html("");
           }
       });
    });
    
    /********************************************************
    * 설명 : Network 삭제 버튼 클릭
   *********************************************************/
    $("#deleteBtn").click(function(){
        if($("#deleteBtn").attr('disabled') == "disabled") return;
        var selected = w2ui['azure_vnetGrid'].getSelection();        
        if( selected.length == 0 ){
            w2alert("선택된 정보가 없습니다.", "Network 삭제");
            return;
        }
        else {
            var record = w2ui['azure_vnetGrid'].get(selected);
            w2confirm({
                title   : "<b>Network 삭제</b>",
                msg     : "Network (" + record.name + ") 안의 <br/> 모든 Resource 정보가 삭제됩니다</font></strong><br/>"
                                       +"<strong><font color='red'>그래도 삭제 하시 겠습니까?</strong><red>"   ,
                yes_text : "확인",
                no_text : "취소",
                height : 350,
                yes_callBack: function(event){
                    deleteAzureResourceGroupInfo(record);
                },
                no_callBack    : function(){
                    w2ui['azure_vnetGrid'].clear();
                    w2ui['azure_deviceGrid'].clear();
                    accountId = record.accountId;
                    doSearch();
                    $("#rgDetailTable td").html("");
                }
            });
        }
    });
    
});

/********************************************************
 * 설명 : Network 목록 조회 Function 
 * 기능 : doSearch
 *********************************************************/
function doSearch() {
	w2ui['azure_vnetGrid'].load("<c:url value='/azureMgnt/network/list/'/>"+accountId);
    doButtonStyle();
    accountId = "";
}

/********************************************************
 * 설명 : Network 정보 상세 조회 Function 
 * 기능 : doSearchRgDetailInfo
 *********************************************************/
function doSearchRgDetailInfo(accountId, networkName){
    w2utils.lock($("#layout_layout_panel_main"), detail_rg_lock_msg, true);
    $.ajax({
        type : "GET",
        url : "/azureMgnt/network/save/detail/"+accountId+"/"+networkName+"",
        contentType : "application/json",
        success : function(data, status) {
            w2utils.unlock($("#layout_layout_panel_main"));
        
            if(data != null){
                $(".networkName").html(data.name);
                $(".subscriptionName").html(data.subscriptionName);
                $(".deployments").html(data.deployments);
            }
            
        },
        error : function(request, status, error) {
            w2utils.unlock($("#layout_layout_panel_main"));
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message, "Azure Network 상세 조회");
        }
    });
}
/********************************************************
 * 설명 : Network 해당 Resource List 조회 Function 
 * 기능 : doSearchRgResourceInfo
 *********************************************************/
function doSearchRgResourceInfo(accountId, networkName){
	w2utils.lock($("#layout_layout_panel_main"), detail_rg_lock_msg, true);
    w2ui['azure_deviceGrid'].load("<c:url value='/azureMgnt/network/save/detail/resource/'/>"+accountId+"/"+networkName);
    
}

/********************************************************
 * 설명 : Azure Network 생성
 * 기능 : saveAzureRGInfo
 *********************************************************/
function saveAzureRGInfo(){
     w2popup.lock(save_lock_msg, true);
    var rgInfo = {
        accountId : $("select[name='accountId']").val(),
        rglocation : $(".w2ui-msg-body select[name='rglocation']").val(),	
        name : $(".w2ui-msg-body input[name='nameTag']").val(),
        networkAddressSpace : $(".w2ui-msg-body input[name='networkAddressSpace']").val(),
        azureSubscriptionId : $(".w2ui-msg-body input[name='azureSubscriptionId']").val(),
        resourceGroupName : $(".w2ui-msg-body select[name='resourceGroupName']").val(),
        subnetName : $(".w2ui-msg-body input[name='subnetName']").val(),
        subnetAddressRange : $(".w2ui-msg-body input[name='subnetAddressRange']").val(),
    }
    
    $.ajax({
        type : "POST",
        url : "/azureMgnt/network/save/",
        contentType : "application/json",
        async : true,
        data : JSON.stringify(rgInfo),
        success : function(status) {
            w2popup.unlock();
            w2popup.close();
            accountId = rgInfo.accountId;
            doSearch();
        }, error : function(request, status, error) {
            w2popup.unlock();
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message);
        }
    });
}

/********************************************************
 * 기능 : setAzureRegion
 * 설명 : 기본  Azure 리전 정보 목록 조회 기능
 *********************************************************/
 /********************************************************
* 애저 전체 리전 정보 :
 centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus,southcentralus,westcentralus,
 northeurope,westeurope,japaneast,japanwest,brazilsouth,australiasoutheast,australiaeast,westindia,
 southindia,centralindia,canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth 

 * 리소스 그룹 만들 수 없는 리전 :
 usgovtexas,usgoviowa,chinanorth,chinaeast,germanycentral,usdodcentral,usgovvirginia,
 usgovarizona,germanynortheast,usdodeast
 ********************************************************/
 function setAzureRegion(){
    $.ajax({
        type : "GET",
        url : '/azureMgnt/network/save/azure/region/list',
        contentType : "application/json",
        dataType : "json",
        success : function(data, status) {
            var result = "";
            for(var i=0; i<data.length; i++){
            	if(data[i] != "usgovtexas" && data[i] != "usgoviowa" && data[i] != "chinanorth" && data[i] != "chinaeast" && data[i] != "germanycentral" && data[i] != "usdodcentral" &&data[i] != "usgovvirginia" &&data[i] != "usgovarizona" && data[i] != "germanynortheast" && data[i] != "usdodeast" ){
                    if(data[i] == "centralus"){
                        result += "<option value='" + data[i] + "'selected >";
                        result += data[i];
                        result += "</option>"; 
                    }else{
                        result += "<option value='" + data[i] + "' >";
                        result += data[i];
                        result += "</option>"; 
                    }
            	}
            }
            console.log(data+"");
            $('#locationList').attr('disabled', false);
            $("#locationList").html(result);
        },
        error : function(request, status, error) {
            w2popup.unlock();
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message);
        }
    });
}
 /********************************************************
  * 기능 : setAzureSubscription
  * 설명 : 기본  Azure 구독 정보 목록 조회 기능
  *********************************************************/
function setAzureSubscription(){
	 accountId = $("select[name='accountId']").val();
	 $.ajax({
	        type : "GET",
	        url : '/azureMgnt/network/save/azure/subscription/list/'+accountId,
	        contentType : "application/json",
	        dataType : "json",
	        success : function(data, status) {
	        	var result = "";
	        	if(data != null){
	                        result += "<option value='"+data.azureSubscriptionId+"' selected >";
	                        result += data.subscriptionName;
	                        result += "</option>"; 
	        	}          
	            $('#subscriptionList').attr('disabled', false);
	            $('#subscriptionList').html(result);
	            console.log(result);
	            //$(".azureSubscription").html(data.subscriptionName);
	        },
	        error : function(request, status, error) {
	            w2popup.unlock();
	            var errorResult = JSON.parse(request.responseText);
	            w2alert(errorResult.message);
	        }
	    });
}

/********************************************************
 * 설명 : Azure Region Onchange 이벤트 기능
 * 기능 : azureRegionOnchange
 *********************************************************/
 function azureRegionOnchange(){
	accountId = $("select[name='accountId']").val();
} 

 /********************************************************
  * 설명 : Azure Subscription Onchange 이벤트 기능
  * 기능 : azureSubscriptionOnchange
  *********************************************************/
  function azureSubscriptionOnchange(){
 	accountId = $("select[name='accountId']").val();
 }
 
  /********************************************************
   * 설명 : Azure Network 삭제
   * 기능 : deleteAzureResourceGroupInfo
   *********************************************************/
  function deleteAzureResourceGroupInfo(record){
      w2popup.lock(delete_lock_msg, true);
      var rgInfo = {
              accountId : record.accountId,
              networkName : record.name
      }
      
      accountId = record.accountId;
      networkName = record.name;
      
      console.log(accountId+networkName+"OOOOOOONNNNEEE");
      $.ajax({
          type : "DELETE",
          url : "/azureMgnt/network/delete/"+accountId+"/"+networkName+"",
          contentType : "application/json",
          async : true,
          data : JSON.stringify(rgInfo),
          success : function(status) {
              w2popup.unlock();
              w2popup.close();
              accountId = rgInfo.accountId;
              w2ui['azure_vnetGrid'].clear();
              w2ui['azure_deviceGrid'].clear();
              $("#rgDetailTable td").html("");
              console.log(accountId+networkName+"TTTTTWWWOOOO");
              doSearch();
          }, error : function(request, status, error) {
              w2popup.unlock();
              $("#rgDetailTable td").html("");
              w2ui['azure_vnetGrid'].clear();
              var errorResult = JSON.parse(request.responseText);
              w2alert(errorResult.message);
          }
      });
  }
 
/********************************************************
 * 설명 : 초기 버튼 스타일
 * 기능 : doButtonStyle
 *********************************************************/
function doButtonStyle() {
    $('#deleteBtn').attr('disabled', true);
}


/****************************************************
 * 기능 : clearMainPage
 * 설명 : 다른페이지 이동시 호출
*****************************************************/
function clearMainPage() {
    $().w2destroy('azure_vnetGrid');
}


/****************************************************
 * 기능 : resize
 * 설명 : 화면 리사이즈시 호출
*****************************************************/
$( window ).resize(function() {
  setLayoutContainerHeight();
});

</script>
<style>
.trTitle {
     background-color: #f3f6fa;
     width: 180px;
 }
td {
    width: 280px;
}
 
</style>
<div id="main">
     <div class="page_site pdt20">인프라 관리 > azure 관리 > <strong>azure Network 관리 </strong></div>
     <div id="azureMgnt" class="pdt20">
        <ul>
            <li>
                <label style="font-size: 14px;">Azure 관리 화면</label> &nbsp;&nbsp;&nbsp; 
                <div class="dropdown" style="display:inline-block;">
                    <a href="#" class="dropdown-toggle iaas-dropdown" data-toggle="dropdown" aria-expanded="false">
                        &nbsp;&nbsp;Network 관리<b class="caret"></b>
                    </a>
                    <ul class="dropdown-menu alert-dropdown">
                        <sec:authorize access="hasAuthority('AZURE_RESOURCE_GROUP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/resourceGroup"/>', 'Azure Resource Group');">Resource Group 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_SUBNET_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/subnet"/>', 'Azure Subnet');">Subnet 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_GATEWAY_SUBNET_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/gatewaySubnet"/>', 'Azure Gateway Subnet');"> Gateway Subnet 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_SECURITY_GROUP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/securityGroup"/>', 'Azure Security Group');">Security Group 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_SECURITY_RULE_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/securityRule"/>', 'Azure Security Rule');">Security Rule 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_PUBILIC_IP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/publicIp"/>', 'Azure Public IP');">Public IP 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_STORAGE_ACCOUNT_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/storageAccount"/>', 'Azure Storage Account');"> Storage Account 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_STORAGE_CONTAINER_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/storageContainer"/>', 'Azure Storage Container');">Storage Container 관리</a></li>
                        </sec:authorize>
                    </ul>
                </div>
            </li>
            
            <li>
                <label style="font-size: 14px">Azure 계정 명</label>
                &nbsp;&nbsp;&nbsp;
                <select name="accountId" id="setAccountList" class="select" style="width: 300px; font-size: 15px; height: 32px;" onchange="setAccountInfo(this.value, 'azure')">
                </select>
                <span id="doSearch" onclick="setDefaultIaasAccount('noPopup','azure');" class="btn btn-info" style="width:80px" >선택</span>
            </li>
        </ul>
    </div>
    <div class="pdt20">
        <div class="title fl">Azure Network 목록</div>
        <div class="fr"> 
        <%--  <sec:authorize access="hasAuthority('AZURE_NETWORK_CREATE')"> --%>
            <sec:authorize access="hasAuthority('AWS_VPC_CREATE')">
            <span id="addBtn" class="btn btn-primary" style="width:120px">생성</span>
            </sec:authorize>
        <%--  <sec:authorize access="hasAuthority('AZURE_NETWORK_DELETE')"> --%>
            <sec:authorize access="hasAuthority('AWS_VPC_DELETE')">
            <span id="deleteBtn" class="btn btn-danger" style="width:120px">삭제</span>
            </sec:authorize>
        </div>
    </div>
    <div id="azure_vnetGrid" style="width:100%; height:305px"></div>

<!-- Network 생성 팝업 -->
<div id="registPopupDiv" hidden="true">
    <form id="azureRGForm" action="POST" style="padding:5px 0 5px 0;margin:0;">
        <div class="panel panel-info" style="height: 350px; margin-top: 7px;"> 
            <div class="panel-heading"><b>Azure Network 생성 정보</b></div>
            <div class="panel-body" style="padding:20px 10px; height:340px; overflow-y:auto;">
                <input type="hidden" name="accountId"/>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Network Name</label>
                    <div>
                        <input name="nameTag" type="text"   maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="Network 태그 명을 입력하세요."/>
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Network 주소 공간</label>
                    <div>
                        <input name="addressSpaceCidr" type="text"   maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="Network  Address Space를 입력하세요."/>
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Subscription</label>
                    <div>
                        <div class="azureSubscription" style="width:300px; font-size: 15px; height: 32px;"></div> 
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Resource Group</label>
                    <div>
                        <select name="resourceGroup" onClick = "azureResourceGroupOnchange()" id="resourceGroupList" class="select" style="width:300px; font-size: 15px; height: 32px;"></select>
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Location</label>
                    <div>
                        <select name="vnetLocation" onClick = "azureRegionOnchange()" id="locationList" class="select" style="width:300px; font-size: 15px; height: 32px;"></select>
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Subnet Name</label>
                    <div>
                        <input name="subnet" type="text"   maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="Subnet Address 범위를 입력하세요."/>
                    </div>
                </div>
                 <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Subnet Address Range 주소 범위</label>
                    <div>
                        <input name="addressRangeCidr" type="text"   maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="Subnet Address 범위를 입력하세요."/>
                    </div>
                </div>
            </div>
        </div>
    </form> 
</div>
<div id="registPopupBtnDiv" hidden="true">
     <button class="btn" id="registBtn" onclick="$('#azureRGForm').submit();">확인</button>
     <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>
    <div class="pdt20" >
        <div class="title fl">azure Network 상세 목록</div>
    </div>
    <div id="azure_rgDetailGrid" style="width:100%; height:128px; margin-top:50px; border-top: 2px solid #c5c5c5; ">
    <table id= "rgDetailTable" class="table table-condensed table-hover">
           <tr>
               <th class= "trTitle">Network Name</th>
               <td class="networkName"></td>
               <th class= "trTitle">Subscription Name</th>
               <td class="subscriptionName"></td>
               <th class= "trTitle">Location</th>
               <td class= "vnetLocation"></td>
           </tr>
        </table>
    </div>
    
        
        <div id="azure_deviceGrid" style="width:100%; min-height:200px; top:0px;"></div>
 
</div>

<div id="registAccountPopupDiv"  hidden="true">
    <input name="codeIdx" type="hidden"/>
    <div class="panel panel-info" style="margin-top:5px;" >    
        <div class="panel-heading"><b>azure 계정 별칭 목록</b></div>
        <div class="panel-body" style="padding:5px 5% 10px 5%;height:65px;">
            <div class="w2ui-field">
                <label style="width:30%;text-align: left;padding-left: 20px; margin-top: 20px;">azure 계정 별칭</label>
                <div style="width: 70%;" class="accountList"></div>
            </div>
        </div>
    </div>
</div>

<div id="registAccountPopupBtnDiv" hidden="true">
    <button class="btn" id="registBtn" onclick="setDefaultIaasAccount('popup','azure');">확인</button>
    <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>


<script>
$(function() {
    $("#azureRGForm").validate({
        ignore : "",
        onfocusout: true,
        rules: {
        	a : {
                required : function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='']").val() );
                },
            }, 
            b: { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body select[name='']").val() );
                }
            }, 
            c: { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body select[name='']").val() );
                }
            }
        }, messages: {
        	a: { 
                 required:  "Name" + text_required_msg
            }, 
            b: { 
                required:  "Subscription "+text_required_msg
                
            }, 
            c: { 
                required:  "Location "+text_required_msg
                
            }
        }, unhighlight: function(element) {
            setSuccessStyle(element);
        },errorPlacement: function(error, element) {
            //do nothing
        }, invalidHandler: function(event, validator) {
            var errors = validator.numberOfInvalids();
            if (errors) {
                setInvalidHandlerStyle(errors, validator);
            }
        }, submitHandler: function (form) {
            saveAzureRGInfo();
        }
    });
});
</script>