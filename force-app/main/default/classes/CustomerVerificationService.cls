/**
 * @description Invocable service for verifying customer identity by account number.
 * Used by the Order Management agent to gate access to order operations.
 */
public with sharing class CustomerVerificationService {
    /**
     * @description Input class for customer verification request
     */
    public class VerificationRequest {
        @InvocableVariable(
            label='Account Number'
            description='The unique account number to verify the customer'
            required=true
        )
        public String account_number;
    }

    /**
     * @description Output class for customer verification response
     */
    public class VerificationResponse {
        @InvocableVariable(
            label='Success'
            description='Indicates if the verification was successful'
        )
        public Boolean success;

        @InvocableVariable(
            label='Customer Name'
            description='The verified customers full name'
        )
        public String customer_name;

        @InvocableVariable(
            label='Customer Email'
            description='The verified customers email address'
        )
        public String customer_email;

        @InvocableVariable(
            label='Customer ID'
            description='The Salesforce record ID of the verified customer'
        )
        public String customer_id;

        @InvocableVariable(
            label='Error Message'
            description='Error message if verification failed'
        )
        public String error_message;
    }

    /**
     * @description Verifies customer identity by looking up the account number
     * @param requests List of VerificationRequest objects
     * @return List of VerificationResponse objects with customer data
     */
    @InvocableMethod(
        label='Verify Customer'
        description='Verifies a customer by their account number and returns customer details'
    )
    public static List<VerificationResponse> verifyCustomer(
        List<VerificationRequest> requests
    ) {
        List<VerificationResponse> responses = new List<VerificationResponse>();

        for (VerificationRequest req : requests) {
            VerificationResponse response = new VerificationResponse();

            // Mock implementation - replace with actual SOQL lookup in your custom code
            if (String.isNotBlank(req.account_number)) {
                response.success = true;
                response.customer_name = 'Acme Corporation';
                response.customer_email = 'jane.doe@acme.com';
                response.customer_id = '001MOCK00000000001';
            } else {
                response.success = false;
                response.error_message = 'Account number is required';
            }

            responses.add(response);
        }

        return responses;
    }
}
