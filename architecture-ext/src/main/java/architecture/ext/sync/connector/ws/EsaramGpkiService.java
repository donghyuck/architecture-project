package architecture.ext.sync.connector.ws;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.gpki.gpkiapi_jni;
import com.gpki.gpkiapi.GpkiApi;
import com.gpki.gpkiapi.cert.X509Certificate;
import com.gpki.gpkiapi.crypto.PrivateKey;
import com.gpki.gpkiapi.storage.Disk;

public class EsaramGpkiService {

	private Log log = LogFactory.getLog(getClass());
	
	byte[] myEnvCert, myEnvKey, mySigCert, mySigKey;
	
	private Map targetServerCertMap = new HashMap();

	// properties
	private String myServerId;
	private String targetServerIdList;
	private String envCertFilePathName;
	private String envPrivateKeyFilePathName;
	private String envPrivateKeyPasswd;
	private String sigCertFilePathName;
	private String sigPrivateKeyFilePathName;
	private String sigPrivateKeyPasswd;
	private String certFilePath;
	private String gpkiLicPath;
	private boolean usingLDAP = true;
	

	public void init() throws Exception {
		
		GpkiApi.init(gpkiLicPath);
		gpkiapi_jni gpki = this.getGPKI();

		if(gpki.API_GetInfo()==0){
			System.out.println(gpki.sReturnString);
			log.error(gpki.sReturnString);
		}else{
			System.out.println(gpki.sDetailErrorString);
			log.error(gpki.sDetailErrorString);
		}
		
		if(targetServerIdList!=null){
			String certIdList[] = targetServerIdList.split(",");
			for(int i = 0 ; i < certIdList.length ; i++){
				String certId = certIdList[i].trim();
				if(!certId.equals("")){
					load(gpki, certId);
				}
			}
		}
		
		log.debug("Loading gpki certificate : myServerId=" + this.getMyServerId());

		X509Certificate _myEnvCert = Disk.readCert(this.getEnvCertFilePathName());
		myEnvCert = _myEnvCert.getCert();

		log.debug(" env reading private key for " + this.getEnvPrivateKeyFilePathName() + " with " + this.getEnvPrivateKeyPasswd());
		
		PrivateKey _myEnvKey = Disk.readPriKey(this.getEnvPrivateKeyFilePathName(), this.getEnvPrivateKeyPasswd());
		myEnvKey = _myEnvKey.getKey();

		
		X509Certificate _mySigCert = Disk.readCert(this.getSigCertFilePathName());
		mySigCert = _mySigCert.getCert();

		log.debug(" sig reading private key for " + this.getSigPrivateKeyFilePathName() + " with " + this.getSigPrivateKeyPasswd());
		
		PrivateKey _mySigKey = Disk.readPriKey(this.getSigPrivateKeyFilePathName(), this.getSigPrivateKeyPasswd());
		mySigKey = _mySigKey.getKey();

		this.finish(gpki);
		log.debug("GpkiUtil initialized\n");
	}

	private void load(gpkiapi_jni gpki, String certId) throws Exception {

		log.debug("Loading gpki certificate : targetServerId="	+ certId);

		X509Certificate cert = (X509Certificate)targetServerCertMap.get(certId);
		if (cert != null) {
			return;
		}

		if (usingLDAP) {
			String ldapUrl = "ldap://10.1.7.140:389/cn=";
			String ldapUri;
			if (certId.charAt(3) > '9') { // 4번째 자리가 알파벳이면..
				ldapUri = ",ou=Group of Server,o=Public of Korea,c=KR";
			} else {
				ldapUri = ",ou=Group of Server,o=Government of Korea,c=KR";
			}
			
			int ret = gpki.LDAP_GetAnyDataByURL("userCertificate;binary", ldapUrl + certId + ldapUri);
			this.checkResult(ret, gpki);
			cert = new X509Certificate(gpki.baReturnArray);
		} else {
			if(certFilePath != null){
				cert = Disk.readCert(certFilePath + File.separator + certId + "_env.cer");	
			}else{
				log.error("not certFilePath");
			}
		}
		targetServerCertMap.put(certId, cert);
	}
	
	private gpkiapi_jni getGPKI(){
		gpkiapi_jni gpki = new gpkiapi_jni();
		if(gpki.API_Init(gpkiLicPath) != 0){
			log.error(gpki.sDetailErrorString);
		}
		return gpki;
	}
	private void finish(gpkiapi_jni gpki){
		if(gpki.API_Finish() != 0){
			log.error(gpki.sDetailErrorString);
		}
	}

	public byte[] encrypt(byte[] plain, String certId) throws Exception {
		X509Certificate targetEnvCert = (X509Certificate)targetServerCertMap.get(certId);
		if (targetEnvCert == null) {
			throw new Exception("Certificate not found : targetServerId=" + certId);
		}
		
		gpkiapi_jni gpki = this.getGPKI();
		try{
			int result = gpki.CMS_MakeEnvelopedData(targetEnvCert.getCert(), plain, gpkiapi_jni.SYM_ALG_NEAT_CBC);
			checkResult(result, "Fail to encrypt message");
	
			byte[] encrypted = gpki.baReturnArray;
			return encrypted;
		}catch(Exception ex){
			throw ex;
		}finally{
			finish(gpki);
		}
	}

	public byte[] decrypt(byte[] encrypted) throws Exception {

		gpkiapi_jni gpki = this.getGPKI();
		try{
			int result = gpki.CMS_ProcessEnvelopedData(myEnvCert, myEnvKey, encrypted);
			checkResult(result, "Fail to decrpyt message");
	
			byte[] plain = gpki.baReturnArray;
			return plain;
		}catch(Exception ex){
			throw ex;
		}finally{
			finish(gpki);
		}
	}

	public byte[] sign(byte[] plain) throws Exception {

		gpkiapi_jni gpki = this.getGPKI();
		try{
			int result = gpki.CMS_MakeSignedData(mySigCert, mySigKey, plain, null);
			checkResult(result, "Fail to sign message");
	
			byte[] signed = gpki.baReturnArray;
			return signed;
		}catch(Exception ex){
			throw ex;
		}finally{
			finish(gpki);
		}
	}

	public byte[] validate(byte[] signed) throws Exception {

		gpkiapi_jni gpki = this.getGPKI();
		try{
			int result = gpki.CMS_ProcessSignedData(signed);
			checkResult(result, "Fail to validate signed message");
			byte[] plain = gpki.baData;
			return plain;
		}catch(Exception ex){
			throw ex;			
		}finally{
			finish(gpki);
		}
	}

	public String encode(byte[] plain) throws Exception {

		gpkiapi_jni gpki = this.getGPKI();
		try{
			int result = gpki.BASE64_Encode(plain);
			checkResult(result, "Fail to encode message");
	
			String encoded = gpki.sReturnString;
			return encoded;
		}catch(Exception ex){
			throw ex;
		}finally{
			finish(gpki);
		}
		
	}

	public byte[] decode(String base64) throws Exception {

		gpkiapi_jni gpki = this.getGPKI();
		try{
			int result = gpki.BASE64_Decode(base64);
			checkResult(result, "Fail to decode base64 message");
	
			byte[] decode = gpki.baReturnArray;
			return decode;
		}catch(Exception ex){
			throw ex;
		}finally{
			finish(gpki);
		}
	}

	private void checkResult(int result, String message) throws Exception {
		if (result != 0) {
			throw new Exception(message + " : gpkiErrorCode=" + result);
		}
	}
	private void checkResult(int result, gpkiapi_jni gpki)throws Exception{
		this.checkResult(result, gpki.sDetailErrorString);
	}
	
	
	public String getMyServerId() {
		return myServerId;
	}

	public void setMyServerId(String myServerId) {
		this.myServerId = myServerId.trim();
	}


	public String getEnvPrivateKeyFilePathName() {
		return envPrivateKeyFilePathName;
	}

	public void setEnvPrivateKeyFilePathName(String envPrivateKeyFilePathName) {
		this.envPrivateKeyFilePathName = envPrivateKeyFilePathName.trim();
	}

	public String getEnvPrivateKeyPasswd() {
		return envPrivateKeyPasswd;
	}

	public void setEnvPrivateKeyPasswd(String envPrivateKeyPasswd) {
		this.envPrivateKeyPasswd = envPrivateKeyPasswd.trim();
	}

	public String getSigPrivateKeyPasswd() {
		return sigPrivateKeyPasswd;
	}

	public void setSigPrivateKeyPasswd(String sigPrivateKeyPasswd) {
		this.sigPrivateKeyPasswd = sigPrivateKeyPasswd.trim();
	}

	public String getSigCertFilePathName() {
		return sigCertFilePathName;
	}

	public void setSigCertFilePathName(String sigCertFilePathName) {
		this.sigCertFilePathName = sigCertFilePathName.trim();
	}

	public String getSigPrivateKeyFilePathName() {
		return sigPrivateKeyFilePathName;
	}

	public void setSigPrivateKeyFilePathName(String sigPrivateKeyFilePathName) {
		this.sigPrivateKeyFilePathName = sigPrivateKeyFilePathName.trim();
	}

	

	public boolean isUsingLDAP() {
		return usingLDAP;
	}

	public void setUsingLDAP(boolean usingLDAP) {
		this.usingLDAP = usingLDAP;
	}

	public String getTargetServerIdList() {
		return targetServerIdList;
	}

	public void setTargetServerIdList(String targetServerIdList) {
		this.targetServerIdList = targetServerIdList;
	}

	public String getGpkiLicPath() {
		return gpkiLicPath;
	}

	public void setGpkiLicPath(String gpkiLicPath) {
		this.gpkiLicPath = gpkiLicPath;
	}

	public String getCertFilePath() {
		return certFilePath;
	}

	public void setCertFilePath(String certFilePath) {
		this.certFilePath = certFilePath;
	}

	public String getEnvCertFilePathName() {
		return envCertFilePathName;
	}

	public void setEnvCertFilePathName(String envCertFilePathName) {
		this.envCertFilePathName = envCertFilePathName;
	}
	
	
	
}
