<%
/* =================================================================
 * 작성일 : 2018.03.20
 * 작성자 : 이정윤
 * 상세설명 : AWS 관리 화면
 * =================================================================
 */ 
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix = "spring" uri = "http://www.springframework.org/tags" %>
 
<script>
var text_required_msg='<spring:message code="common.text.vaildate.required.message"/>';//을(를) 입력하세요.
var detail_lock_msg='<spring:message code="common.search.detaildata.lock"/>';//상세 조회 중 입니다.
var detail_rg_lock_msg='<spring:message code="common.search.detaildata.lock"/>';//상세 조회 중 입니다.
var text_cidr_msg='<spring:message code="common.text.validate.cidr.message"/>';//CIDR 대역을 확인 하세요.
var text_injection_msg='<spring:message code="common.text.validate.sqlInjection.message"/>';//입력하신 값은 입력하실 수 없습니다.
var accountId ="";
var bDefaultAccount = "";

var search_lock_msg = '<spring:message code="common.update.data.lock"/>';//등록 중 입니다.
$(function() {
    
    bDefaultAccount = setDefaultIaasAccountList("aws");
    
    $('#aws_routeTableGrid').w2grid({
        name: 'aws_routeTableGrid',
        method: 'GET',
        msgAJAXerror : 'AWS Route Table 목록 조회 실패',
        header: '<b>Property 목록</b>',
        multiSelect: false,
        show: { 
        		selectColumn: false,
                footer: true},
        style: 'text-align: center',
        columns    : [
                    {field: 'recid',     caption: 'recid', hidden: true}
                   //,{field: 'accountId',     caption: 'accountId', hidden: true}
                   ,{field: 'nameTag', caption: 'Name', size: '20%', style: 'text-align:center'}
                   ,{field: 'routeTableId', caption: 'Route Table ID', size: '20%', style: 'text-align:center'}
                   ,{field: 'associationCnt', caption: 'Explicitly Associated With', size: '20%', style: 'text-align:center'}
                   ,{field: 'mainYN', caption: 'Main', size: '30%', style: 'text-align:center'} 
                   ,{field: 'vpcId', caption: 'VPC', size: '30%', style: 'text-align:center'}
                   ],
        onSelect: function(event) {
            event.onComplete = function() {
            	$('#addRouteBtn').attr('disabled', false);
            	$('#subnetAssociationBtn').attr('disabled', false);
            	var region = $("select[name='region']").val();
            	var accountId =  w2ui.aws_routeTableGrid.get(event.recid).accountId;
                var routeTableId = w2ui.aws_routeTableGrid.get(event.recid).routeTableId;
                doSearchRouteDetail(accountId,routeTableId);
                doSearchSubnetDetail(accountId,routeTableId);
            }
        },
        onUnselect: function(event) {
            event.onComplete = function() {
            	$('#addRouteBtn').attr('disabled', true);
            	$('#subnetAssociationBtn').attr('disabled', true);
            	w2ui['aws_routeGrid'].clear();
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
    
    $('#aws_routeGrid').w2grid({
        name: 'aws_routeGrid',
        method: 'GET',
        msgAJAXerror : 'AWS 계정을 확인해주세요.',
        header: '<b>Route 목록</b>',
        multiSelect: false,
        show: {    
                selectColumn: false,
                footer: true},
        style: 'text-align: center',
        columns    : [
                     {field: 'recid',     caption: 'recid', hidden: true}
                   , {field: 'accountId',     caption: 'accountId', hidden: true}
                   , {field: 'routeTableId',     caption: 'routeTableId', hidden: true}
                   , {field: 'destinationIpv4CidrBlock', caption: 'Destination', size: '50%', style: 'text-align:center'}
                   , {field: 'targetId', caption: 'Target', size: '50%', style: 'text-align:center'}
                   , {field: 'status', caption: 'Status', size: '50%', style: 'text-align:center'}
                   , {field: 'propagatedYN', caption: 'Propagated', size: '50%', style: 'text-align:center'}
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
    
    $('#aws_subnetGrid').w2grid({
        name: 'aws_subnetGrid',
        method: 'GET',
        msgAJAXerror : 'AWS 계정을 확인해주세요.',
        header: '<b>Associated Subnets 목록</b>',
        selectType : 'row',
        multiSelect: false,
        show: {  
        	    selectColumn: false,
                footer: true},
        style: 'text-align: center',
        columns    : [
                     {field: 'recid',     caption: 'recid',  size: '40px', style: 'text-align:center'}
                   , {field: 'accountId',     caption: 'accountId', hidden: true}
                   , {field: 'subnetId', caption: 'subnetId', size: '150px', style: 'text-align:center'}
                   , {field: 'destinationIpv4CidrBlock', caption: 'IPv4 CIDR', size: '150px', style: 'text-align:center'}
                   , {field: 'ipv6CidrBlock', caption: 'IPv6', size: '40px', style: 'text-align:center'}
                   , {field: 'routeTableId',     caption: 'RouteTableId', size: '150px', style: 'text-align:center'}
                   ],
                   onLoad: function(event){
                       event.onComplete = function(){
                           $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', true);
                       }
                   },
                   onSelect: function(event) {
                       event.onComplete = function() {
                           $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', false);
                       }
                   },
                   onUnselect: function(event) {
                       event.onComplete = function(){
                           $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', true);
                       }
                   },
                   onError: function(event){
                       // comple
                   }
    });
    
    
    /* $('#aws_subnetAssociationGrid').w2grid({
        name: 'aws_subnetAssociationGrid',
        method: 'GET',
        msgAJAXerror : 'AWS 계정을 확인해주세요.',
        header: '<b> Association 가능 한 Subnets 목록</b>',
        selectType : 'row',
        multiSelect: false,
        show: {  
        	    selectColumn: false,
                footer: true},
        style: 'text-align: center',
        columns: [
            { field: 'recid', caption: 'Recid', hidden: true},
            { field: 'accountId', caption: 'accountId', hidden: true},
            { field: 'subnetId', caption: 'Subnet ID', size: '150px', style: 'text-align: center'},
            { field: 'destinationIpv4CidrBlock', caption: 'IPv4 CIDR', size: '150px', style: 'text-align: center', render : function(record){
                if(record.destinationIpv4CidrBlock == ""){
                    return "-";
                }else{
                    return record.destinationIpv4CidrBlock;
                }
            }},
            { field: 'ipv6CidrBlock', caption: 'IPv6', size: '40px', style: 'text-align: center', render : function(record){
                if(record.ipv6CidrBlock == ""){
                    return "-";
                }else{
                    return record.ipv6CidrBlock;
                }
            }},
            { field: 'routeTableId', caption: 'RouteTable ID',  size: '120px', style: 'text-align: center', render : function(record){
                if(record.routeTableId == ""){
                    return "-";
                }else{
                    return record.routeTableId;
                }
            }}
            ],
            onLoad: function(event){
                event.onComplete = function(){
                    $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', true);
                }
            },
            onSelect: function(event) {
                event.onComplete = function() {
                    $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', false);
                }
            },
            onUnselect: function(event) {
                event.onComplete = function(){
                    $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', true);
                }
            },
            onError: function(event){
                // comple
            }
    });  */
    
    /*************************** *****************************
     * 설명 :  AWS Route Table Create 팝업 화면
     *********************************************************/
    $("#addBtn").click(function(){
        if($("#addBtn").attr('disabled') == "disabled") return;
        w2popup.open({
            title   : "<b>AWS Route Table 생성 </b>",
            width   : 500,
            height  : 350,
            modal   : true,
            body    : $("#registPopupDiv").html(),
            buttons : $("#registPopupBtnDiv").html(),
            onOpen : function(event){
                event.onComplete = function(){
                	setAwsVpcIdList();
                }                   
            },onClose:function(event){
                initsetting();
                doSearch();
            }
        });
    }); 
    
    /*************************** *****************************
     * 설명 :  AWS Route Create 팝업 화면
     *********************************************************/
    $("#addRouteBtn").click(function(){
        if($("#addRouteBtn").attr('disabled') == "disabled") return;
        w2popup.open({
            title   : "<b>AWS Route Add </b>",
            width   : 500,
            height  : 350,
            modal   : true,
            body    : $("#registRoutePopupDiv").html(),
            buttons : $("#registRoutePopupBtnDiv").html(),
            onOpen : function(event){
                event.onComplete = function(){
                	setAwsTargetList();
                }                   
            },onClose:function(event){
                initsetting();
                doSearch();
            }
        });
    }); 
    
    
});


/********************************************************
 * 설명 : 추가 그리드 및 폼 값 초기화
 *********************************************************/
var config = {
         layouti: {
             name: 'layouti',
             padding: 4,
             panels: [
                 { type: 'left', size: '480px', minSize: 300},
                 { type: 'main', size: '450px',minSize: 300}
             ]
         },
         grid: {
        	 name: 'aws_subnetAssociationGrid',
             method: 'GET',
             msgAJAXerror : 'AWS 계정을 확인해주세요.',
             header: '<b> Association 가능 한 Subnets 목록</b>',
             selectType : 'row',
             recid   : 'recid',
             multiSelect: false,
             show: {  
             	    selectColumn: false,
                    footer: true},
             style: 'text-align: center',
             columns: [
                 { field: 'recid', caption: 'Recid',  size: '40px', style: 'text-align: center'},
                 { field: 'accountId', caption: 'accountId', hidden: true},
                 { field: 'subnetId', caption: 'Subnet ID', size: '150px', style: 'text-align: center'},
                 { field: 'destinationIpv4CidrBlock', caption: 'IPv4 CIDR', size: '150px', style: 'text-align: center', render : function(record){
                     if(record.destinationIpv4CidrBlock == ""){
                         return "-";
                     }else{
                         return record.destinationIpv4CidrBlock;
                     }
                 }},
                 { field: 'ipv6CidrBlock', caption: 'IPv6', size: '40px', style: 'text-align: center', render : function(record){
                     if(record.ipv6CidrBlock == ""){
                         return "-";
                     }else{
                         return record.ipv6CidrBlock;
                     }
                 }},
                 { field: 'routeTableId', caption: 'RouteTable ID',  size: '120px', style: 'text-align: center', render : function(record){
                     if(record.routeTableId == ""){
                         return "-";
                     }else{
                         return record.routeTableId;
                     }
                 }}
                 ],
                 onLoad: function(event){
                     event.onComplete = function(){
                         $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', true);
                     }
                 },
                 onSelect: function(event) {
                     event.onComplete = function() {
                         $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', false);
                     }
                 },
                 onUnselect: function(event) {
                     event.onComplete = function(){
                         $('#w2ui-popup #deleteInterfaceBtn').attr('disabled', true);
                     }
                 },
                 onError: function(event){
                     // comple
                 }
        	 
         }
         }
$(function () {
    // initialization in memory
    $().w2layout(config.layouti);
    $().w2grid(config.grid);
});
/********************************************************
 * 설명 : Route Table 목록 조회 Function
 * 기능 : doSearch
 *********************************************************/
function doSearch() {
    region = $("select[name='region']").val();
    if(region == null) region = "us-west-2";
    w2ui['aws_routeTableGrid'].load("<c:url value='/awsMgnt/routeTable/list/"+accountId+"/"+region+"'/>","",function(event){});
    doButtonStyle();
 }


/********************************************************
 * 설명 : Route Table 해당 Route List 조회 Function 
 * 기능 : doSearchRouteDetail
 *********************************************************/
function doSearchRouteDetail(accountId, routeTableId){
	w2utils.lock($("#layout_layout_panel_main"), detail_rg_lock_msg, true);
	var region = $("select[name='region']").val();
    w2ui['aws_routeGrid'].load("<c:url value='/awsMgnt/routeTable/save/detail/route/'/>"+accountId+"/"+region+"/"+routeTableId);
    w2utils.unlock($("#layout_layout_panel_main"));
}

/********************************************************
 * 설명 : Route Table 해당 Subnet List 조회 Function 
 * 기능 : doSearchSubnetDetail
 *********************************************************/
function doSearchSubnetDetail(accountId, routeTableId){
	w2utils.lock($("#layout_layout_panel_main"), detail_rg_lock_msg, true);
	var region = $("select[name='region']").val();
	//show selected colum effects nth-child number show=6 hide=5
	var vpcId= document.querySelector("#aws_routeTableGrid .w2ui-selected td:nth-child(5) div").innerHTML; 
    w2ui['aws_subnetGrid'].load("<c:url value='/awsMgnt/routeTable/save/detail/subnet/'/>"+accountId+"/"+region+"/"+routeTableId+"/"+vpcId);
    w2utils.unlock($("#layout_layout_panel_main"));
}

/********************************************************
 * 설명 : Route Table 해당VPC에 대한 Subnet Assoication List 조회 Function 
 * 기능 : doSearchSubnetAssociationDetail
 *********************************************************/
/* function doSearchSubnetAssociationDetail(){
	w2utils.lock($("#layout_layout_panel_main"), detail_rg_lock_msg, true);
	var region = $("select[name='region']").val();
	var accountId = $("select[name='accountId']").val();
	//show selected colum effects nth-child number show=6 hide=5
	var vpcId= document.querySelector("#aws_routeTableGrid .w2ui-selected td:nth-child(5) div").innerHTML; 
    w2ui['aws_subnetAssociationGrid'].load("<c:url value='/awsMgnt/routeTable/save/detail/subnet/'/>"+accountId+"/"+region+"/"+vpcId);
    w2utils.unlock($("#layout_layout_panel_main"));
}
 */

/********************************************************
 * 설명 : Route Table 생성
 * 기능 : awsRouteTableCreate
 *********************************************************/
function awsRouteTableCreate(){
    w2popup.lock( "생성중", true);
    var routeTableInfo = {
            accountId : $("select[name='accountId']").val(),
            region :  $("select[name='region']").val(),
            nameTag : $(".w2ui-msg-body input[name='nameTag']").val(),
            vpcId :$(".w2ui-msg-body select[name='vpcId']").val()
        }
    
$.ajax({
    type : "POST",
    url : "/awsMgnt/routeTable/save",
    contentType : "application/json",
    async : true,
    data : JSON.stringify(routeTableInfo),
    success : function(status) {
        w2popup.unlock();
        w2popup.close();    
        initsetting();
    },
    error : function(request, status, error) {
        w2popup.unlock();
        initsetting();
        var errorResult = JSON.parse(request.responseText);
        w2alert(errorResult.message, "");
    }
  });
}

/********************************************************
 * 설명 : Route 생성
 * 기능 : awsRouteCreate
 *********************************************************/

function awsRouteCreate(){
	w2utils.lock($("#layout_layout_panel_main"), "", true);
	w2popup.lock( "생성 중 입니다.", true);
    routeInfo = { 
    		accountId : $("select[name='accountId']").val(),
            region :  $("select[name='region']").val(), 
            //show selected colum config affects td nth childe number  show =3 hide =2
            routeTableId : document.querySelector("#aws_routeTableGrid .w2ui-selected td:nth-child(2) div").innerHTML,
            destinationIpv4CidrBlock : $(".w2ui-msg-body input[name='destinationIpv4CidrBlock']").val(),
            targetId : $(".w2ui-msg-body select[name='targetId']").val()
            }
$.ajax({
    type : "POST",
    url : "/awsMgnt/routeTable/route/add",
    contentType : "application/json",
    async : true,
    data : JSON.stringify(routeInfo),
    success : function(status) {
    	w2utils.unlock($("#layout_layout_panel_main"));
    	w2popup.unlock();
    	w2popup.close();    
        
    },
    error : function(request, status, error) {
        w2utils.unlock($("#layout_layout_panel_main"));
        w2popup.unlock();
        var errorResult = JSON.parse(request.responseText);
        w2alert(errorResult.message, "");
    }
  });
}

/********************************************************
 * 기능 : setAwsVpcIdList
 * 설명 : 기본  Azure VPC 목록 조회 기능
 *********************************************************/
function setAwsVpcIdList(){
	 w2popup.lock(detail_lock_msg, true);
    var accountId = $("select[name='accountId']").val();
    var region = $("select[name='region']").val();
    $.ajax({
           type : "GET",
           url : '/awsMgnt/routeTable/vpcIdList/'+accountId+'/'+region,
           contentType : "application/json",
           dataType : "json",
           success : function(data, status) {
               var result = "";
               if(data != null){
                   for(var i=0; i<data.length; i++){
                           result += "<option value='" + data[i].vpcId + "' >";
                           result += data[i].vpcId;
                           if(data[i].nameTag != null){
                           result += "  |  ";
                           result += data[i].nameTag;
                           }
                           result += "</option>"; 
                   }
               }
               
               $('#vpcInfoDiv #vpcInfo').html(result);
               w2popup.unlock();
           },
           error : function(request, status, error) {
               w2popup.unlock();
               var errorResult = JSON.parse(request.responseText);
               w2alert(errorResult.message);
           }
       });
}

/********************************************************
 * 기능 : setAwsTargetList
 * 설명 : 기본  Azure Target 목록 조회 기능
 *********************************************************/
function setAwsTargetList(){
	 w2popup.lock(detail_lock_msg, true);
    var accountId = $("select[name='accountId']").val();
    var region = $("select[name='region']").val();
    //show selected colum effects nth-child number show=6 hide=5
    var vpcId= document.querySelector("#aws_routeTableGrid .w2ui-selected td:nth-child(5) div").innerHTML; 
    $.ajax({
           type : "GET",
           url : '/awsMgnt/routeTable/route/list/targetList/'+accountId+'/'+region+'/'+vpcId,
           contentType : "application/json",
           dataType : "json",
           success : function(data, status) {
               var result = "";
               if(data != null){
                   for(var i=0; i<data.length; i++){
                	   
                           result += "<option value='" + data[i] + "' >";
                           result += data[i];
                           result += "</option>"; 
                   }
               }
               
               $('#targetInfoDiv #targetInfo').html(result);
               w2popup.unlock();
           },
           error : function(request, status, error) {
               w2popup.unlock();
               var errorResult = JSON.parse(request.responseText);
               w2alert(errorResult.message);
           }
       });
}


/********************************************************
 * 기능 : setAwsSubnetIdList
 * 설명 : 기본  Azure Subnet 목록 조회 기능
 *********************************************************/
function setAwsSubnetIdList(){
	 w2popup.lock(detail_lock_msg, true);
    var accountId = $("select[name='accountId']").val();
    var region = $("select[name='region']").val();
    $.ajax({
           type : "GET",
           url : '/awsMgnt/routeTable/subnetIdList/'+accountId+'/'+region,
           contentType : "application/json",
           dataType : "json",
           success : function(data, status) {
               var result = "";
               if(data != null){
                   for(var i=0; i<data.length; i++){
                           result += "<option value='" + data[i].subnetId + "' >";
                           result += data[i].subnetId;
                           result += "  |  ";
                           result += data[i].nameTag;
                           result += "</option>"; 
                   }
               }
               
               $('#vpcInfoDiv #vpcInfo').html(result);
               w2popup.unlock();
           },
           error : function(request, status, error) {
               w2popup.unlock();
               var errorResult = JSON.parse(request.responseText);
               w2alert(errorResult.message);
           }
       });
}

/*************************** *****************************
 * 설명 :  AWS Subnet Association 팝업 화면
 *********************************************************/
function subnetAssociation() {
    if($("#subnetAssociationBtn").attr('disabled') == "disabled") return;
    var region = $("select[name='region']").val();
	var accountId = $("select[name='accountId']").val();
    var selected = w2ui['aws_routeTableGrid'].getSelection();
    var record = w2ui['aws_routeTableGrid'].get(selected);
    w2popup.open({
        title   : "<b> Edit Subnet Association </b>",
        width   : 1000,
        height  : 550,
        modal   : true,
        body    : "<div id='subnetAssociationPopupDiv' style='position: absolute; width:99%; height:95%; margin:5px 0;'></div>",
        buttons : $("#subnetAssociationPopupBtnDiv").html(),
        onOpen : function(event){
            event.onComplete = function(){
            	$('.w2ui-popup #subnetAssociationPopupDiv').w2render('layouti');
            	//w2ui.layouti.content('left', $('#subnetAssocitaionAvaliablePopupDiv').html());
            	 w2ui.layouti.content('left', w2ui.aws_subnetAssociationGrid);
            	w2ui['aws_subnetAssociationGrid'].load("<c:url value='/awsMgnt/routeTable/save/detail/subnet/'/>"+accountId+"/"+region+"/"+record.vpcId);
			    //doSearchSubnetAssociationDetail();
	            w2ui['layouti'].content('main', $('#subnetAssociationsPopupDiv').html());
	            //doSearchSubnetDetail(accountId,record.routeTableId);
	           
	            // w2ui['aws_subnetGrid'].load("<c:url value='/awsMgnt/routeTable/save/detail/subnet/'/>"+accountId+"/"+region+"/"+record.routeTableId+"/"+record.vpcId);
            }                   
        },onClose:function(event){
            //initsetting();
            //doSearch();
        }
    });
 }
 


/********************************************************
 * 기능 : initsetting
 * 설명 : 기본 설정값 초기화
 *********************************************************/
function initsetting(){
     bDefaultAccount="";
     w2ui['aws_routeTableGrid'].clear();
     w2ui['aws_routeGrid'].clear();
     w2ui['aws_subnetGrid'].clear();
     doSearch();
}

/********************************************************
 * 설명 : 초기 버튼 스타일
 * 기능 : doButtonStyle
 *********************************************************/
function doButtonStyle() {
    $('#addRouteBtn').attr('disabled', true);
    $('#subnetAssociationBtn').attr('disabled', true);
}


/********************************************************
 * 기능 : clearMainPage
 * 설명 : 다른페이지 이동시 호출
 *********************************************************/
function clearMainPage() {
    $().w2destroy('aws_routeTableGrid');
    $().w2destroy('aws_routeGrid');
    $().w2destroy('aws_subnetGrid');
}

/********************************************************
 * 기능 : resize
 * 설명 : 화면 리사이즈시 호출
 *********************************************************/
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
     <div class="page_site pdt20">인프라 관리 > AWS 관리 > <strong>AWS Route Tables 관리 </strong></div>
     <div id="awsMgnt" class="pdt20">
        <ul>
            <li>
                <label style="font-size: 14px">AWS 관리 화면</label> &nbsp;&nbsp;&nbsp; 
                <div class="dropdown" style="display:inline-block;">
                    <a href="#" class="dropdown-toggle iaas-dropdown" data-toggle="dropdown" aria-expanded="false">
                        &nbsp;&nbsp;Route Table 관리<b class="caret"></b>
                    </a>
                    <ul class="dropdown-menu alert-dropdown">
                        <sec:authorize access="hasAuthority('AWS_SECURITY_GROUP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/awsMgnt/securityGroup"/>', 'AWS SECURITY GROUP');">Security Group 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AWS_KEYPAIR_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/awsMgnt/keypair"/>', 'AWS KEYPAIR');">KeyPair 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AWS_SUBNET_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/awsMgnt/subnet"/>', 'AWS SUBNET');">Subnet 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AWS_VPC_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/awsMgnt/vpc"/>', 'AWS VPC');">VPC 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AWS_INTERNET_GATEWAY_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/awsMgnt/internetGateway"/>', 'AWS Internet GateWay');">Internet Gateway 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AWS_NAT_GATEWAY_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/awsMgnt/vpc/natGateway"/>', 'AWS NAT GateWay');">Internet Gateway 관리</a></li>
                        </sec:authorize>
                    </ul>
                </div>
            </li>
            <li>
                <label style="font-size: 14px">AWS Region</label>
                &nbsp;&nbsp;&nbsp;
                <select name="region" onchange="awsRegionOnchange();" id="regionList" class="select" style="width:300px; font-size: 15px; height: 32px;"></select>
            </li>
            <li>
                <label style="font-size: 14px">AWS 계정 명</label>
                &nbsp;&nbsp;&nbsp;
                <select name="accountId" id="setAccountList" class="select" style="width: 300px; font-size: 15px; height: 32px;" onchange="setAccountInfo(this.value, 'aws')">
                </select>
                <span id="doSearch" onclick="setDefaultIaasAccount('noPopup','aws');" class="btn btn-info" style="width:80px" >선택</span>
            </li>
        </ul>
    </div>

    <div class="pdt20">
        <div class="title fl">AWS Route Table 목록</div>
        <div class="fr"> 
         <%-- <sec:authorize access="hasAuthority('AWS_ROUTE_TABLE_CREATE')"> --%>
            <span id="addBtn" class="btn btn-primary" style="width:140px">라우트 테이블 생성</span>
            <span id="addRouteBtn" class="btn btn-info"  onclick="" style="width:140px" > Route 추가 </span>
            <span id="subnetAssociationBtn" class="btn  btn-warning" onclick="subnetAssociation()" style="left: 20px;" > Subnet Associations 수정 </span>
        </div>
    </div>
    <div id="aws_routeTableGrid" style="width:100%; height:305px"></div>
   
    <div style="margin-top:20px;">
    <div class="title fl">Routes 정보</div>
    <div id="aws_routeGrid" style="width:100%; height:150px"></div>
    </div>
    
    <!-- <div style="margin-top:20px;">
    <div class="title fl">Explicitly Associated Subnets 정보</div>
    <div class="showSubnets"id="aws_subnetGrid" style="width:100%; height:150px"></div>
    </div> -->
</div>

<!-- AWS Route Table Create 팝업 Div-->
<div id="registPopupDiv" hidden="true">
<form id="awsRouteTableForm" action="POST" style="padding:5px 0 5px 0;margin:0;">
    <div id="awsRouteTableCreate" >
         <div class="panel panel-info" style="height: 250px; margin-top: 7px;"> 
            <div class="panel-heading"><b>AWS Route Table 생성</b></div>
            
           <div class="w2ui-field">
               <label style="width:100%; margin-top:20px; text-align: left; padding-left: 20px;"> Name Tag</label>
           </div>
            <div class="w2ui-field">
               <div id="nameTagDiv" style="width:420px;  padding-left: 20px;">
               	<input id="nameTag" style="width:400px;" name="nameTag" placeholder=""/>
               </div>
           </div>
           <div class="w2ui-field">
               <label style="width:100%; margin-top:20px; text-align: left; padding-left: 20px;"> VPC </label>
           </div>
           <div class="w2ui-field">    
               <div id="vpcInfoDiv" style="width:420px;  padding-left: 20px;">
               	<select id="vpcInfo" style="width:400px;" name="vpcId"><option></option></select>
               </div>
           </div>
		</div>   
    </div> 
</form>
</div>
<div id="registPopupBtnDiv" hidden="true">
     <button class="btn btn-primary" id="registBtn" onclick="$('#awsRouteTableForm').submit();">확인</button>
     <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>

<!-- AWS Route Add 팝업 Div-->
<div id="registRoutePopupDiv" hidden="true">
<form id="awsRouteForm" action="POST" style="padding:5px 0 5px 0;margin:0;">
    <div id="awsRouteCreate" >
         <div class="panel panel-info" style="height: 250px; margin-top: 7px;"> 
            <div class="panel-heading"><b>AWS Route 추가</b></div>
            
           <div class="w2ui-field">
               <label style="width:100%; margin-top:20px; text-align: left; padding-left: 20px;"> Destination Ip4 CIDR </label>
           </div>
            <div class="w2ui-field">
               <div id="destinationIdDiv" style="width:420px;  padding-left: 20px;">
               	<input id="destinationId" style="width:400px;" name="destinationIpv4CidrBlock" placeholder=""/>
               </div>
           </div>
           <div class="w2ui-field">
               <label style="width:100%; margin-top:20px; text-align: left; padding-left: 20px;"> Target </label>
           </div>
           <div class="w2ui-field">    
               <div id="targetInfoDiv" style="width:420px;  padding-left: 20px;">
               	<select id="targetInfo" style="width:400px;" name="targetId"><option></option></select>
               </div>
           </div>
		</div>   
    </div> 
</form>
</div>
<div id="registRoutePopupBtnDiv" hidden="true">
     <button class="btn btn-primary" id="registBtn" onclick="$('#awsRouteForm').submit();">확인</button>
     <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>

<!-- AWS subnetAssociationsPopupDiv Subnet 팝업 Div-->

<!-- <div id="subnetAssocitaionAvaliablePopupDiv" hidden="true">
<label> Association 가능한 Subnet 목록</label>
		 <div class="showSubnets" id="aws_subnetAssociationGrid" style="width:470px; height:350px"></div>
     <label style="margin-top:10px; margin-left:100px;">연결 할 Subnet을 선택하고 연결 버튼을 누르세요.</label>
     <span id="associateBtn" onclick="awsAssociateSubnet();" class="btn btn-primary" style="width:90px; margin-left:200px;" >연결</span>
</div>  -->


<div id="subnetAssociationsPopupDiv" hidden="true">
	<label>Explicitly Associated Subnet 목록</label>
    <div class="showSubnets" id="aws_subnetGrid" style="width:500px; height:350px"></div>
    <label style="margin-top:10px; margin-left:100px;">해제 할 Subnet을 선택하고 해제 버튼을 누르세요.</label>
    <span id="disassociateBtn" onclick="awsDisassociateSubnet();" class="btn btn-danger" style="width:90px; margin-left:200px;" >해제</span>
</div> 
<div id="subnetAssociationPopupBtnDiv" hidden="true">
    <button id="popClose" class="btn btn-info" style="width:90px"  onclick="w2popup.close();">확인</button>
</div>

<div id="registAccountPopupDiv"  hidden="true">
    <input name="codeIdx" type="hidden"/>
    <div class="panel panel-info" style="margin-top:5px;" >    
        <div class="panel-heading"><b>AWS 계정 별칭 목록</b></div>
        <div class="panel-body" style="padding:5px 5% 10px 5%;height:65px;">
            <div class="w2ui-field">
                <label style="width:30%;text-align: left;padding-left: 20px; margin-top: 20px;">AWS 계정 별칭</label>
                <div style="width: 70%;" class="accountList"></div>
            </div>
        </div>
    </div>
</div>

<div id="registAccountPopupBtnDiv" hidden="true">
    <button class="btn" id="registBtn" onclick="setDefaultIaasAccount('popup','aws');">확인</button>
    <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>

<script>
$(function() {
	$("#awsRouteTableForm").validate({
        ignore : "",
        onfocusout: true,
        rules: {
        	nameTag : {
        		sqlInjection :   function(){
                    return $(".w2ui-msg-body input[name='nameTag']").val();
                }
            },
        	vpcId : {
                required : function(){
                    return checkEmpty( $(".w2ui-msg-body select[name='vpcId']").val() );
                },
            }
        }, messages: {
        	nameTag: { 
        		sqlInjection : text_injection_msg
           },
        	vpcId: { 
                 required:  "VPC" + text_required_msg
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
        	awsRouteTableCreate();
        }
    });
	
	$.validator.addMethod( "destinationIpv4CidrBlock", function( value, element, params ) {
        return /^((\b|\.)(0|1|2(?!5(?=6|7|8|9)|6|7|8|9))?\d{1,2}){4}(-((\b|\.)(0|1|2(?!5(?=6|7|8|9)|6|7|8|9))?\d{1,2}){4}|\/((0|1|2|3(?=1|2))\d|\d))\b$/.test(params);
    }, text_cidr_msg );
	
	$("#awsRouteForm").validate({
        ignore : "",
        onfocusout: true,
        rules: {
        	destinationIpv4CidrBlock : {
        		required : function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='destinationIpv4CidrBlock']").val() );
                }, destinationIpv4CidrBlock : function(){
                    return $(".w2ui-msg-body input[name='destinationIpv4CidrBlock']").val();
                }
            },
        	targetId : {
                required : function(){
                    return checkEmpty( $(".w2ui-msg-body select[name='targetId']").val() );
                }
            }
        }, messages: {
        	destinationIpv4CidrBlock: { 
                required:  "Destination CIDR" + text_required_msg
           },
        	targetId: { 
                 required:  "Target" + text_required_msg
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
        	awsRouteCreate();
        }
    });
	
});

</script>
