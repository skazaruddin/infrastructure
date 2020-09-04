
import java.io.IOException;

import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.ws.WebServiceMessage;
import org.springframework.ws.client.core.WebServiceMessageCallback;
import org.springframework.ws.client.core.WebServiceTemplate;
import org.springframework.ws.soap.SoapHeader;
import org.springframework.ws.soap.saaj.SaajSoapMessage;
import org.springframework.ws.transport.context.TransportContext;
import org.springframework.ws.transport.context.TransportContextHolder;
import org.springframework.ws.transport.http.HttpComponentsConnection;
import org.springframework.xml.transform.StringSource;

@Component
public class StudentServiceClient {

	private static final Logger log = LoggerFactory.getLogger(StudentServiceClient.class);

	private static final String URL = "http://localhost:8080/";

	@Autowired
	private WebServiceTemplate webServiceTemplate;

	public GetStudentDetailsResponse getStudent(StudentDetails student) {

		GetStudentDetailsRequest request = new GetStudentDetailsRequest();
		request.setId(student.getId());

		log.info("Requesting quote for " + 1);

		GetStudentDetailsResponse response = (GetStudentDetailsResponse) webServiceTemplate.marshalSendAndReceive(
				"http://localhost:8080/ws/student", request,

				new WebServiceMessageCallback() {
					public void doWithMessage(WebServiceMessage message) throws IOException {

						TransportContext context = TransportContextHolder.getTransportContext();
						HttpComponentsConnection connection = (HttpComponentsConnection) context.getConnection();
						connection.addRequestHeader("X-API-KEY", "asnndkas");

						if (message instanceof SaajSoapMessage) {

//							---------------------------------Added this part--------------------------------------- 
							// Web Service was using very old format of message exchange so we have to manually replace the headers.
							{
								SOAPMessage soapMessage = ((SaajSoapMessage) message).getSaajMessage();
								SOAPPart soapPart = soapMessage.getSOAPPart();
								SOAPEnvelope envelope = soapPart.getEnvelope();
								SOAPHeader soapheader = soapMessage.getSOAPHeader();
								SOAPBody body = soapMessage.getSOAPBody();
								SOAPFault fault = body.getFault();

								envelope.removeNamespaceDeclaration(envelope.getPrefix());
//												
								
								// Replace the prefix with "soapenv" and SOAP_ENV_NAMESPACE from the xsd file
							// e.g. 	soapEnvelope.addNamespaceDeclaration("soapenv", "http://schemas.xmlsoap.org/soap/envelope/");
							
								envelope.addNamespaceDeclaration("soapenv", SOAP_ENV_NAMESPACE);
//								
								envelope.setPrefix("soapenv");
								soapheader.setPrefix("soapenv");
								body.setPrefix("soapenv");
                soapMessage.saveChanges();

							}
//							---------------------------------End of the part--------------------------

							try {
//								This part will remain as it was in our file.
								
								SaajSoapMessage soapMessage = (SaajSoapMessage) message;

								SoapHeader soapHeader = soapMessage.getSoapHeader();

								StringBuffer header = new StringBuffer();
								header.append("<Header>");
								header.append("<Authentication>");
								header.append("<MyID>");

								StringSource headerSource = new StringSource(
										"<MYHeader>\n<Auth>\n<MyID>1312</MyID>\n<Pwd>test213</Pwd>\n</Auth>\n</MYHeader>");
								Transformer transformer = TransformerFactory.newInstance().newTransformer();
								transformer.transform(headerSource, soapHeader.getResult());
							} catch (TransformerFactoryConfigurationError | TransformerException e) {
								e.printStackTrace();
							}
						}
					}
				});
		return response;
	}

}
