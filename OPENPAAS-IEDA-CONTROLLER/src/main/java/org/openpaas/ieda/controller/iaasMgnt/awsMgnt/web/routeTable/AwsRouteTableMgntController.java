package org.openpaas.ieda.controller.iaasMgnt.awsMgnt.web.routeTable;

import java.security.Principal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.openpaas.ieda.awsMgnt.web.routeTable.dao.AwsRouteTableMgntVO;
import org.openpaas.ieda.awsMgnt.web.routeTable.dto.AwsRouteTableMgntDTO;
import org.openpaas.ieda.awsMgnt.web.routeTable.service.AwsRouteTableMgntService;
import org.openpaas.ieda.controller.iaasMgnt.awsMgnt.web.vpc.AwsVpcMgntController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class AwsRouteTableMgntController {
	@Autowired AwsRouteTableMgntService awsRouteTableMgntService;
	private final static Logger LOG = LoggerFactory.getLogger(AwsVpcMgntController.class);
	 
	/****************************************************************
     * @project : Paas 플랫폼 설치 자동화
     * @description : Elastic Ip 화면 이동
     * @title : goAwsElasticIpMgnt
     * @return : String
    *****************************************************************/
    @RequestMapping(value="/awsMgnt/routeTable", method=RequestMethod.GET)
    public String goAwsElasticIpMgnt(){
    	 if (LOG.isInfoEnabled()) {
             LOG.info("================================================> AWS Route Table 관리 화면 이동");
         }
        return "iaas/aws/routeTable/awsRouteTableMgnt";
    }
    
    /***************************************************
     * @project : AWS 인프라 관리 대시보드
     * @description : AWS RouteTable 목록 조회
     * @title : getAwsRouteTableInfoList
     * @return : ResponseEntity<HashMap<String, Object>>
     ***************************************************/
     @RequestMapping(value="/awsMgnt/routeTable/list/{accountId}/{region}", method=RequestMethod.GET)
     @ResponseBody
     public ResponseEntity<HashMap<String, Object>> getAwsRouteTableInfoList(@PathVariable("accountId") int accountId, @PathVariable("region") String region, Principal principal){
         if (LOG.isInfoEnabled()) {
             LOG.info("================================================> AWS Route Table 목록 조회");
         }
         HashMap<String, Object> map = new HashMap<String, Object>();
          
         List<AwsRouteTableMgntVO> list = awsRouteTableMgntService.getAwsRouteTableInfoList(accountId ,region, principal);
         if(list != null){
             map.put("total", list.size());
             map.put("records", list);
         }
         return new ResponseEntity<HashMap<String, Object>>(map, HttpStatus.OK);
     }

     /***************************************************
      * @project : AWS 관리 대시보드
      * @description : AWS Route 목록 조회
      * @title : getAwsRouteList
      * @return : ResponseEntity<?>
      ***************************************************/
     @RequestMapping(value="/awsMgnt/routeTable/save/detail/route/{accountId}/{region}/{routeTableId}", method=RequestMethod.GET)
     @ResponseBody
     public ResponseEntity<HashMap<String, Object>> getAwsRouteList(@PathVariable("accountId") int accountId, @PathVariable("region") String region, Principal principal, @PathVariable("routeTableId") String routeTableId){
         
     	List<AwsRouteTableMgntVO> list  = awsRouteTableMgntService.getAwsRouteList(accountId, region, principal, routeTableId);
     	HashMap<String, Object> map = new HashMap<String, Object>();
         if(list != null){
             map.put("total", list.size());
             map.put("records", list);
         }
     	return new ResponseEntity<HashMap<String, Object>>(map, HttpStatus.OK);
     }
     
     /***************************************************
      * @project : AWS 관리 대시보드
      * @description : AWS  해당 RouteTable에 대한 Associated Subnets 목록 조회
      * @title : getAwsSubnetList
      * @return : ResponseEntity<?>
      ***************************************************/
     @RequestMapping(value="/awsMgnt/routeTable/save/detail/subnet/{accountId}/{region}/{routeTableId}/{vpcId}", method=RequestMethod.GET)
     @ResponseBody
     public ResponseEntity<HashMap<String, Object>> getAwsAssociatedWithThisTableSubnetList
     (@PathVariable("accountId") int accountId, @PathVariable("region") String region, Principal principal, @PathVariable("routeTableId") String routeTableId, @PathVariable("vpcId") String vpcId){
         
     	List<AwsRouteTableMgntVO> list  = awsRouteTableMgntService.getAwsAssociatedWithThisTableSubnetList(accountId, region, principal, routeTableId, vpcId);
     	HashMap<String, Object> map = new HashMap<String, Object>();
         if(list != null){
             map.put("total", list.size());
             map.put("records", list);
         }
     	return new ResponseEntity<HashMap<String, Object>>(map, HttpStatus.OK);
     }
     
    
     /***************************************************
      * @project : AWS 관리 대시보드
      * @description : AWS RouteTable의 해당 VPC에 대한 Subnets 목록 조회
      * @title : getAwsSubnetList
      * @return : ResponseEntity<?>
      ***************************************************/
     @RequestMapping(value="/awsMgnt/routeTable/save/detail/subnet/{accountId}/{region}/{vpcId}", method=RequestMethod.GET)
     @ResponseBody
     public ResponseEntity<HashMap<String, Object>> getAwsSubnetList(@PathVariable("accountId") int accountId, @PathVariable("region") String region, Principal principal, @PathVariable("vpcId") String vpcId){
         
      	List<AwsRouteTableMgntVO> list  = awsRouteTableMgntService.getAwsSubnetList(accountId, region, principal, vpcId);
      	HashMap<String, Object> map = new HashMap<String, Object>();
          if(list != null){
              map.put("total", list.size());
              map.put("records", list);
          }
      	return new ResponseEntity<HashMap<String, Object>>(map, HttpStatus.OK);
      }
     
     
     /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS VPC ID List 조회
      * @title : getAwsVpcIdList
      * @return : ResponseEntity<AwsRouteTableMgntVO> 
      ***************************************************/
     @RequestMapping(value="/awsMgnt/routeTable/vpcIdList/{accountId}/{region}", method=RequestMethod.GET)
     @ResponseBody
     public ResponseEntity<List<AwsRouteTableMgntVO>> getAwsVpcIdList (@PathVariable("accountId") int accountId, @PathVariable("region") String region,  Principal principal){
    	 if (LOG.isInfoEnabled()) {
             LOG.info("================================================> AWS VPC ID 목록 조회");
         }
    	 List<AwsRouteTableMgntVO> list = awsRouteTableMgntService.getAwsVpcIdList(accountId, region, principal);
    	 return new ResponseEntity<List<AwsRouteTableMgntVO>>(list,HttpStatus.OK);
     }
     
     /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS Target List 조회
      * @title : getAwsTargetIdList
      * @return : ResponseEntity<AwsRouteTableMgntVO> 
      ***************************************************/
     @RequestMapping(value="/awsMgnt/routeTable/route/list/targetList/{accountId}/{region}/{vpcId}", method=RequestMethod.GET)
     @ResponseBody
     public ResponseEntity<ArrayList<String>> getAwsTargetInfoList(@PathVariable("accountId") int accountId, @PathVariable("region") String region,  Principal principal, @PathVariable("vpcId") String vpcId){
    	 if (LOG.isInfoEnabled()) {
             LOG.info("================================================> AWS Target 목록 조회");
         }
    	 ArrayList<String> list = awsRouteTableMgntService.getAwsTargetInfoList(accountId, region, principal, vpcId);
    	 return new ResponseEntity<ArrayList<String>>(list,HttpStatus.OK);
     }
     /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS Route Table생성
      * @title : saveAwsRouteTableInfo
      * @return : ResponseEntity<?>
      ***************************************************/
     @RequestMapping(value="/awsMgnt/routeTable/save", method=RequestMethod.POST)
     @ResponseBody
     public ResponseEntity<?> saveAwsRouteTableInfo(@RequestBody AwsRouteTableMgntDTO dto, Principal principal){
         if (LOG.isInfoEnabled()) {
             LOG.info("================================================> AWS RouteTable 생성");
         }  
         awsRouteTableMgntService.saveAwsRouteTableInfo(dto, principal);
         return new ResponseEntity<>(HttpStatus.CREATED);
     } 
     
     /***************************************************
      * @project : AWS 인프라 관리 대시보드
      * @description : AWS Route 추가
      * @title : addAwsRouteInfo
      * @return : ResponseEntity<?>
      ***************************************************/
     @RequestMapping(value="/awsMgnt/routeTable/route/add", method=RequestMethod.POST)
     @ResponseBody
     public ResponseEntity<?> addAwsRouteInfo(@RequestBody AwsRouteTableMgntDTO dto, Principal principal){
         if (LOG.isInfoEnabled()) {
             LOG.info("================================================> AWS Route 추가");
         }  
         awsRouteTableMgntService.addAwsRouteInfo(dto, principal);
         return new ResponseEntity<>(HttpStatus.CREATED);
     } 
}
