package org.openpaas.ieda.awsMgnt.web.routeTable.service;

import java.security.Principal;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.openpaas.ieda.awsMgnt.web.routeTable.dao.AwsRouteTableMgntVO;
import org.openpaas.ieda.awsMgnt.web.routeTable.dto.AwsRouteTableMgntDTO;
import org.openpaas.ieda.common.exception.CommonException;
import org.openpaas.ieda.iaasDashboard.web.account.dao.IaasAccountMgntVO;
import org.openpaas.ieda.iaasDashboard.web.common.service.CommonIaasService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.amazonaws.regions.Region;
import com.amazonaws.services.ec2.model.InternetGateway;
import com.amazonaws.services.ec2.model.NatGateway;
import com.amazonaws.services.ec2.model.Route;
import com.amazonaws.services.ec2.model.RouteTable;
import com.amazonaws.services.ec2.model.Subnet;
import com.amazonaws.services.ec2.model.Vpc;

@Service
public class AwsRouteTableMgntService {
    @Autowired AwsRouteTableMgntApiService awsRouteTableMgntApiService;
    @Autowired CommonIaasService commonIaasService;
    @Autowired MessageSource message;
    
    /***************************************************
     * @project : AWS 인프라 관리 대시보드
     * @description : AWS NAT Gateway 목록 조회
     * @title : getAwsrouteTableInfoList
     * @return : List<AwsrouteTableMgntVO>
     ***************************************************/
     public List<AwsRouteTableMgntVO> getAwsRouteTableInfoList( int accountId, String regionName, Principal principal ) {
         IaasAccountMgntVO vo =  getAwsAccountInfo(principal, accountId);
         Region region = getAwsRegionInfo(regionName);
         List<RouteTable> apiAwsRouteTableList = awsRouteTableMgntApiService.getAwsRouteTableListApiFromAws(vo, region.getName());
         List<AwsRouteTableMgntVO> awsrouteTableList = new ArrayList<AwsRouteTableMgntVO>();
         if(apiAwsRouteTableList.size()!= 0){
             for ( int i=0; i<apiAwsRouteTableList.size(); i++ ){
                 RouteTable routeTable = apiAwsRouteTableList.get(i);
                 AwsRouteTableMgntVO awsrouteTableVO = new AwsRouteTableMgntVO();
                 awsrouteTableVO.setRouteTableId(routeTable.getRouteTableId());
                
                 if(routeTable.getTags().size()!=0){
                     awsrouteTableVO.setNameTag(routeTable.getTags().get(0).getValue().toString());
                 }else{
                     awsrouteTableVO.setNameTag(" - ");
                 }
                 if(routeTable.getAssociations().size() != 0){
                     int k =1;
                     for(int j=0; j< routeTable.getAssociations().size(); j++){
                     String subnetId = routeTable.getAssociations().get(j).getSubnetId();
                     if(subnetId != null){
                         k++;
                         awsrouteTableVO.setAssociationCnt(k-1);
                         }else{
                         awsrouteTableVO.setAssociationCnt(0);    
                         }
                     }
                 }else{
                     awsrouteTableVO.setAssociationCnt(0);
                 }
                   if(routeTable.getAssociations().size() != 0){
                       for(int m=0; m < routeTable.getAssociations().size(); m++){
                         if(routeTable.getAssociations().get(m).getMain() == null){
                          
                              awsrouteTableVO.setMainYN(false);
                         }else{
                             awsrouteTableVO.setMainYN(routeTable.getAssociations().get(m).getMain());
                          }
                       }
                      }else{
                          awsrouteTableVO.setMainYN(false);
                          }
                 if(routeTable.getVpcId()!= null){
                 awsrouteTableVO.setVpcId(routeTable.getVpcId().toString());
                 }else{
                     awsrouteTableVO.setVpcId(" - ");
                 }
                 awsrouteTableVO.setRecid(i);
                 awsrouteTableVO.setAccountId(accountId);
                 awsrouteTableList.add(awsrouteTableVO);
             }
         }else{
             AwsRouteTableMgntVO awsrouteTableVO = new AwsRouteTableMgntVO();
              awsrouteTableVO.setNameTag("-");
              awsrouteTableVO.setRouteTableId("-");
              awsrouteTableList.add(awsrouteTableVO);
         }
         return awsrouteTableList;
         }
     
     /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS Route Table에 대한 Route 목록 조회 
      * @title : getAwsRouteList
      * @return :  List<AwsRouteTableMgntVO> 
      ***************************************************/
     public  List<AwsRouteTableMgntVO> getAwsRouteList(int accountId, String regionName, Principal principal, String routeTableId  ){
         IaasAccountMgntVO vo =  getAwsAccountInfo(principal, accountId);
         Region region = getAwsRegionInfo(regionName);
         List<RouteTable> apiAwsRouteTableList = awsRouteTableMgntApiService.getAwsRouteTableListApiFromAws(vo, region.getName());
         List<AwsRouteTableMgntVO> list = new ArrayList<AwsRouteTableMgntVO>();
        
         for (int i=0; i<apiAwsRouteTableList.size(); i++ ){
             String tableId = apiAwsRouteTableList.get(i).getRouteTableId().toString();
             if( tableId.equals(routeTableId)){
                 RouteTable routeTable = apiAwsRouteTableList.get(i);
             for (int j=0; j<routeTable.getRoutes().size(); j++){
                 
                 AwsRouteTableMgntVO awsRTmgntVo = new AwsRouteTableMgntVO();
                 awsRTmgntVo.setRouteTableId(routeTableId);
                 
                 //Propagated 여부
                 int size = routeTable.getPropagatingVgws().size();
                 String sizeString = Integer.toString(size);
                 Boolean exists =! sizeString.equals("0");
                 awsRTmgntVo.setPropagatedYN(exists);
                 
                 Route route = routeTable.getRoutes().get(j);
                 awsRTmgntVo.setDestinationIpv4CidrBlock(route.getDestinationCidrBlock());
                 awsRTmgntVo.setTargetId(route.getGatewayId());
                 if(route.getNatGatewayId()!= null){
                     awsRTmgntVo.setTargetId(route.getNatGatewayId());
                 }
                 awsRTmgntVo.setStatus(route.getState());
                 awsRTmgntVo.setRecid(j);
                 awsRTmgntVo.setAccountId(vo.getId());
                 
                 list.add(awsRTmgntVo);
                 }
             }
         }
         return list;
     }

    /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS Route Table에 대한 Subnet 목록 조회 
      * @title : getAwsSubnetList
      * @return :  List<AwsRouteTableMgntVO> 
      ***************************************************/
    public  List<AwsRouteTableMgntVO> getAwsSubnetList(int accountId, String regionName, Principal principal,  String vpcId  ){
         IaasAccountMgntVO vo =  getAwsAccountInfo(principal, accountId);
         Region region = getAwsRegionInfo(regionName);
         List<Subnet> apiAwsSubnetList = awsRouteTableMgntApiService.getAwsSubnetInfoListApiFromAws(vo,region.getName());
         // List<RouteTable> apiAwsRouteTableList = awsRouteTableMgntApiService.getAwsRouteTableListApiFromAws(vo,region.getName());
          //List<String> theRouteTables = new ArrayList<String>();
          //RouteTable routeTable = apiAwsRouteTableList.get(0);
         //String theRouteTableId = routeTable.getAssociations().get(0).getRouteTableId();
         //String associatedSubnetId = routeTable.getAssociations().get(0).getSubnetId();
        List<RouteTable> apiAwsRouteTableList = awsRouteTableMgntApiService.getAwsRouteTableListApiFromAws(vo,region.getName());
        List<AwsRouteTableMgntVO> list = new ArrayList<AwsRouteTableMgntVO>();
        for (int i=0; i<apiAwsSubnetList.size(); i++ ){
            String subnetVpcId = apiAwsSubnetList.get(i).getVpcId().toString();
            if( subnetVpcId.equals(vpcId)){
                List<String> subnetVpcIds = new ArrayList<String>();
                subnetVpcIds.add(subnetVpcId);
                for(int j=0; j<subnetVpcIds.size();j++){
                    AwsRouteTableMgntVO awsRTmgntVo = new AwsRouteTableMgntVO();
                    awsRTmgntVo.setSubnetId (apiAwsSubnetList.get(i).getSubnetId());
                    awsRTmgntVo.setDestinationIpv4CidrBlock(apiAwsSubnetList.get(i).getCidrBlock());
                    int vp6size = apiAwsSubnetList.get(i).getIpv6CidrBlockAssociationSet().size();
                    if(vp6size!=0){
                        for(int k=0; k<vp6size; k++){
                            String ipv6Block = "";
                            ipv6Block += apiAwsSubnetList.get(i).getIpv6CidrBlockAssociationSet().get(k).getIpv6CidrBlock();
                            awsRTmgntVo.setIpv6CidrBlock(ipv6Block);
                        } 
                    }else if(vp6size == 0){
                        awsRTmgntVo.setIpv6CidrBlock("-");
                    }
                    
                    for(int h=0; h<apiAwsRouteTableList.size(); h++){
                        RouteTable routeTable = apiAwsRouteTableList.get(h);
                        if(routeTable.getVpcId().equals(subnetVpcIds.get(j))){
                          String apiSubnetId = apiAwsSubnetList.get(i).getSubnetId();
                          if(routeTable.getAssociations().size() != 0 ){
                            int y = routeTable.getAssociations().size();
                            for(int x=0; x<y; x++){
                              String tableSubnetId = routeTable.getAssociations().get(x).getSubnetId();
                              if(apiSubnetId.equals(tableSubnetId)){
                                awsRTmgntVo.setRouteTableId(routeTable.getAssociations().get(x).getRouteTableId());
                              }
                            }
                          }
                        }
                    }
                    awsRTmgntVo.setRecid(j);
                    awsRTmgntVo.setAccountId(accountId);
                    list.add(awsRTmgntVo);
                }
            }
        }
        return list;
     }
     
    
     /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS 해당 Route Table에 대해 associated Subnet 목록 조회 
      * @title : getAwsAssociatedWithThisTableSubnetList
      * @return :  List<AwsRouteTableMgntVO> 
      ***************************************************/
     public  List<AwsRouteTableMgntVO> getAwsAssociatedWithThisTableSubnetList(int accountId, String regionName, Principal principal, String routeTableId, String vpcId  ){
         IaasAccountMgntVO vo =  getAwsAccountInfo(principal, accountId);
         Region region = getAwsRegionInfo(regionName);
         
         List<RouteTable> apiAwsRouteTableList = awsRouteTableMgntApiService.getAwsRouteTableListApiFromAws(vo,region.getName());
         List<String> associatedSubnetIds = new ArrayList<String>();
         List<String> theRouteTables = new ArrayList<String>();
         List<AwsRouteTableMgntVO> list = new ArrayList<AwsRouteTableMgntVO>();
         
         int rtSize = apiAwsRouteTableList.size();
         for(int m=0; m< rtSize; m++){
         RouteTable routeTable = apiAwsRouteTableList.get(m);
             int aSize = routeTable.getAssociations().size();
             for (int n=0; n< aSize; n++){
             String theRouteTableId = routeTable.getAssociations().get(n).getRouteTableId();
                 if (theRouteTableId.equals(routeTableId)){
                     if(!routeTable.getAssociations().get(n).getMain()){
                     String associatedSubnetId = routeTable.getAssociations().get(n).getSubnetId();
                     String theRouteTable = routeTable.getAssociations().get(n).getRouteTableId();
                     associatedSubnetIds.add(associatedSubnetId);
                     theRouteTables.add(theRouteTable);
                    
                     }else if(routeTable.getAssociations().get(n).getMain()){
                         String associationId = routeTable.getAssociations().get(n).getRouteTableAssociationId();
                         String theRouteTable = routeTable.getAssociations().get(n).getRouteTableId();
                         associatedSubnetIds.add(associationId);
                         theRouteTables.add(theRouteTable);
                     }
                     }
               }
         }
         int x = associatedSubnetIds.size();
         if(x!=0){
         List<Subnet> apiAwsSubnetList = awsRouteTableMgntApiService.getAwsSubnetInfoListApiFromAws(vo,region.getName());
         for (int i=0; i<apiAwsSubnetList.size(); i++ ){
             String subnetId = apiAwsSubnetList.get(i).getSubnetId().toString();
             
             for(int y=0; y<x; y++){
                 String theSubnetId = associatedSubnetIds.get(y).toString();
                 String theRouteTableId = theRouteTables.get(y).toString();
                 if(theSubnetId.equals(subnetId)){
             String subnetVpcId = apiAwsSubnetList.get(i).getVpcId().toString();
             if( subnetVpcId.equals(vpcId)){
                 List<String> subnetVpcIds = new ArrayList<String>();
                 subnetVpcIds.add(subnetVpcId);
                 for(int j=0; j<subnetVpcIds.size();j++){
                     AwsRouteTableMgntVO awsRTmgntVo = new AwsRouteTableMgntVO();
                     awsRTmgntVo.setSubnetId (apiAwsSubnetList.get(i).getSubnetId());
                     awsRTmgntVo.setDestinationIpv4CidrBlock(apiAwsSubnetList.get(i).getCidrBlock());
                     int vp6size = apiAwsSubnetList.get(i).getIpv6CidrBlockAssociationSet().size();
                     if(vp6size!=0){
                         for(int k=0; k<vp6size; k++){
                             String ipv6Block = "";
                             ipv6Block += apiAwsSubnetList.get(i).getIpv6CidrBlockAssociationSet().get(k).getIpv6CidrBlock();
                             awsRTmgntVo.setIpv6CidrBlock(ipv6Block);
                         } 
                     }else if(vp6size == 0){
                        awsRTmgntVo.setIpv6CidrBlock(" - ");
                 }
                     awsRTmgntVo.setRouteTableId(theRouteTableId);
                     awsRTmgntVo.setRecid(y);
                     awsRTmgntVo.setAccountId(accountId);
                     
                     list.add(awsRTmgntVo);
                 }
             }
             }else if(theSubnetId.startsWith("rtbassoc-")){}
            }
        }
        }
         return list;
     }
     
     
     /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS VPC ID 목록 조회
      * @title : getAwsVpcIdList
      * @return : List<AwsRouteTableMgntVO>
      ***************************************************/
      public List<AwsRouteTableMgntVO> getAwsVpcIdList ( int accountId, String regionName, Principal principal ) {
          IaasAccountMgntVO vo =  getAwsAccountInfo(principal, accountId);
          Region region = getAwsRegionInfo(regionName);
          List<Vpc> apiVpcIdList = awsRouteTableMgntApiService.getAwsVpcIdListApiFromAws(vo, region.getName());
          List<AwsRouteTableMgntVO> awsVpcIdList = new ArrayList<AwsRouteTableMgntVO>();
          for (int i=0; i< apiVpcIdList.size(); i++){
              Vpc vpc = apiVpcIdList.get(i);
              
              AwsRouteTableMgntVO awsRouteTableVO = new AwsRouteTableMgntVO();
              awsRouteTableVO.setVpcId(vpc.getVpcId().toString());
              if(vpc.getTags().size()!=0){
                  String result ="";
                  for(int j=0; j<vpc.getTags().size(); j++){
                      result += vpc.getTags().get(j).getValue().toString();
                      if(result != "null"){
                      awsRouteTableVO.setNameTag(result);
                      }else if(result == "null"){
                      awsRouteTableVO.setNameTag("");
                      }
                  }
              }
              awsRouteTableVO.setRecid(i);
              awsRouteTableVO.setAccountId(accountId);
              awsVpcIdList.add(awsRouteTableVO);
          }
          
          return awsVpcIdList;
      }
      
      /***************************************************
       * @project : AWS 인프라 관리 대시보드
       * @description : AWS Target 목록 조회
       * @title : getAwsTargetInfoList
       * @return : List<AwsRouteTableMgntVO>
       ***************************************************/
      public  ArrayList<String> getAwsTargetInfoList( int accountId, String regionName, Principal principal, String vpcId ) {
          IaasAccountMgntVO vo =  getAwsAccountInfo(principal, accountId);
          Region region = getAwsRegionInfo(regionName);
          List<InternetGateway> apiAwsIGWList = awsRouteTableMgntApiService.getAwsIGWListApiFromAws(vo, region.getName());
          int cnt = 1;
          ArrayList<String> targets = new ArrayList<String>();
          if(apiAwsIGWList!=null && apiAwsIGWList.size() !=0){
          for (int i=0; i< apiAwsIGWList.size(); i++){
              InternetGateway igw = apiAwsIGWList.get(i);
              for (int m=0; m<igw.getAttachments().size(); m++){
                 if( igw.getAttachments().get(m).getVpcId().equals(vpcId)){
                 if(igw.getTags().size()!=0){
                      String result ="";
                      for(int j=0; j<igw.getTags().size(); j++){
                          result += igw.getTags().get(j).getValue().toString();
                          if(result != "null"){
                              targets.add(i, igw.getInternetGatewayId().toString()+" | "+result);
                          }else if(result == "null"){
                              targets.add(i, igw.getInternetGatewayId().toString());
                    }
                  }
                }
              targets.add(i, igw.getInternetGatewayId().toString());
              cnt++;
              }
            }
          }
          }
          List<NatGateway> apiAwsNatGWList = awsRouteTableMgntApiService.getAwsNatGatewayListApiFromAws(vo, region.getName());
          if( apiAwsNatGWList != null && apiAwsNatGWList.size() != 0){
          for (int k=0; k<apiAwsNatGWList.size(); k++){
              NatGateway natgw = apiAwsNatGWList.get(k);
              if(natgw !=null){
              if(natgw.getState().equals("avaliable") && natgw.getVpcId().equals(vpcId)){
              targets.add(cnt-1+k, natgw.getNatGatewayId().toString());
              }
              }
            }
          }
          /*if(targets = null && targets.size() == 0){
        	 targets.add(0,"");
          }*/
          return targets;
      }
      /***************************************************
       * @project : AWS 인프라 관리 대시보드
       * @description : AWS Route Table 생성
       * @title : saveAwsRouteTableInfo
       * @return : void
       ***************************************************/
      public void saveAwsRouteTableInfo(AwsRouteTableMgntDTO dto, Principal principal) {
          IaasAccountMgntVO vo =  getAwsAccountInfo(principal, dto.getAccountId());
          Region region = getAwsRegionInfo(dto.getRegion());
          try{
              awsRouteTableMgntApiService.createAwsRouteTableFromAws(vo, region.getName(), dto);
          }catch (Exception e) {
              throw new CommonException(
                      message.getMessage("common.badRequest.exception.code", null, Locale.KOREA), message.getMessage("common.badRequest.message", null, Locale.KOREA), HttpStatus.BAD_REQUEST);
          }
      }
      
      /***************************************************
       * @project : AWS 인프라 관리 대시보드
       * @description : AWS Route Table 생성
       * @title : saveAwsRouteTableInfo
       * @return : void
       ***************************************************/
      public void addAwsRouteInfo (AwsRouteTableMgntDTO dto, Principal principal) {
          IaasAccountMgntVO vo =  getAwsAccountInfo(principal, dto.getAccountId());
          Region region = getAwsRegionInfo(dto.getRegion());
          try{
              awsRouteTableMgntApiService.createAwsRouteFromAws(vo, region.getName(), dto);
          }catch (Exception e) {
              throw new CommonException(
                      message.getMessage("common.badRequest.exception.code", null, Locale.KOREA), message.getMessage("common.badRequest.message", null, Locale.KOREA), HttpStatus.BAD_REQUEST);
          }
      }
      
      
     /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS 계정 정보가 실제 존재 하는지 확인 및 상세 조회
      * @title : getAwsAccountInfo
      * @return : IaasAccountMgntVO
      ***************************************************/
      public IaasAccountMgntVO getAwsAccountInfo(Principal principal, int accountId){
          return commonIaasService.getIaaSAccountInfo(principal, accountId, "aws");
      }
          
      /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS 리전 명 조회
      * @title : getAwsRegionInfo
      * @return : Region
      ***************************************************/
      public Region getAwsRegionInfo(String regionName) {
          return commonIaasService.getAwsRegionInfo(regionName);
      }
  
     
    
}
