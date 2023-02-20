enum MessageHeaderType {
  BindingRequest,
  BindingResponse,
  BindingErrorResponse,
  SharedSecretRequest,
  SharedSecretResponse,
  SharedSecretErrorResponse
}

const int BINDINGREQUEST = 1;
const int BINDINGRESPONSE = 257;
const int BINDINGERRORRESPONSE = 273;
const int SHAREDSECRETREQUEST = 2;
const int SHAREDSECRETRESPONSE = 258;
const int SHAREDSECRETERRORRESPONSE = 274;
