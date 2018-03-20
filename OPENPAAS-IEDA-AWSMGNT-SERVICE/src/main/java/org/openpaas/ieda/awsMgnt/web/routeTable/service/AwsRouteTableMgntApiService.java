package org.openpaas.ieda.awsMgnt.web.routeTable.service;

import java.util.ArrayList;
import java.util.List;

import org.openpaas.ieda.awsMgnt.web.routeTable.dto.AwsRouteTableMgntDTO;
import org.openpaas.ieda.common.web.common.service.CommonApiService;
import org.openpaas.ieda.iaasDashboard.web.account.dao.IaasAccountMgntVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.ec2.AmazonEC2Client;
import com.amazonaws.services.ec2.AmazonEC2ClientBuilder;
import com.amazonaws.services.ec2.model.Address;
import com.amazonaws.services.ec2.model.AssociateAddressRequest;
import com.amazonaws.services.ec2.model.AssociateAddressResult;
import com.amazonaws.services.ec2.model.CreateRouteRequest;
import com.amazonaws.services.ec2.model.CreateRouteTableRequest;
import com.amazonaws.services.ec2.model.RouteTable;
import com.amazonaws.services.ec2.model.Vpc;
import com.google.api.services.compute.Compute.Routes;
import com.microsoft.azure.management.network.Route;

@Service
public class AwsRouteTableMgntApiService {

	@Autowired
	CommonApiService commonApiService;
	/***************************************************
    * @project : Paas 플랫폼 설치 자동화
    * @description : 공통 AmazonEC2Client 객체 생성 
    * @title : getAmazonEC2Client
    * @return : AmazonEC2Client
    ***************************************************/
    public AmazonEC2Client getAmazonEC2Client(IaasAccountMgntVO vo, String region){
        AWSStaticCredentialsProvider provider = commonApiService.getAwsStaticCredentialsProvider(vo.getCommonAccessUser(), vo.getCommonAccessSecret());
        AmazonEC2Client ec2 =  (AmazonEC2Client)AmazonEC2ClientBuilder.standard().withRegion(region).withCredentials(provider).build();
        return ec2;
    }
    
    /***************************************************
     * @project : AWS 인프라 관리 대시보드
     * @description : AWS RouteTable 목록 조회 실제 API 호출 (Route info / subnet association info nested)
     * @title : getAwsRouteTableListApiFromAws
     * @return : List<RouteTable>
     ***************************************************/
    public List<RouteTable> getAwsRouteTableListApiFromAws(IaasAccountMgntVO vo, String regionName) {
    	AmazonEC2Client ec2 =  getAmazonEC2Client(vo, regionName);
    	List<RouteTable> routetables = ec2.describeRouteTables().getRouteTables();
    	//routetables.get(0).getAssociations().get(0).getSubnetId();
    	return routetables;
    }
    
    
    
    /***************************************************
     * @project : AWS 인프라 관리 대시보드
     * @description : AWS Route Table 생성 실제 API 호출
     * @title : createAwsRouteTableFromAws
     * @return : void
     ***************************************************/
    public void createAwsRouteTableFromAws(IaasAccountMgntVO vo, String regionName, AwsRouteTableMgntDTO dto){
    	AmazonEC2Client ec2 =  getAmazonEC2Client(vo, regionName);
    	String vpcId = dto.getVpcId();
    	CreateRouteTableRequest request = new CreateRouteTableRequest().withVpcId(vpcId);
    	ec2.createRouteTable(request);
    }
    
    
    /***************************************************
     * @project : AWS 인프라 관리 대시보드
     * @description : AWS Route 생성 실제 API 호출
     * @title : createAwsRouteFromAws
     * @return : void
     ***************************************************/
    public void createAwsRouteFromAws(IaasAccountMgntVO vo, String regionName, AwsRouteTableMgntDTO dto){
    	AmazonEC2Client ec2 =  getAmazonEC2Client(vo, regionName);
    	String destinationCidrBlock = dto.getDestinationIpv4CidrBlock();
    	String egressOnlyInternetGatewayId = dto.getTargetId();
    	CreateRouteRequest request = new CreateRouteRequest().withDestinationCidrBlock(destinationCidrBlock).withEgressOnlyInternetGatewayId(egressOnlyInternetGatewayId);
    	ec2.createRoute(request);
    }
    
   
     
    /***************************************************
    * @project : AWS 인프라 관리 대시보드
    * @description : AWS Address 목록 조회 실제 API 호출
    * @title : getAwsAddressListApiFromAws
    * @return : List<Address>
    ***************************************************/
    public List<Address> getAwsAddressListApiFromAws(IaasAccountMgntVO vo, String regionName) {
        AmazonEC2Client ec2 =  getAmazonEC2Client(vo, regionName);
        List<Address> addresses = ec2.describeAddresses().getAddresses();
        return addresses;
    }
    
    /***************************************************
    * @project : AWS 인프라 관리 대시보드
    * @description : AWS VPC 목록 조회 실제 API 호출
    * @title : getAwsVpcInfoListApiFromAws
    * @return : List<Vpc>
    ***************************************************/
    public List<Vpc> getAwsVpcInfoListApiFromAws(IaasAccountMgntVO vo, String regionName) {
        AmazonEC2Client ec2 =  getAmazonEC2Client(vo, regionName);
        List<Vpc> vpcs = ec2.describeVpcs().getVpcs();
        return vpcs;
    }
    
}
