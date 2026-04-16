/**
 * @description Test class for CustomerVerificationService
 * Tests customer verification by account number
 */
@IsTest
private class CustomerVerificationServiceTest {
    @IsTest
    static void testVerifyCustomerSuccess() {
        CustomerVerificationService.VerificationRequest request = new CustomerVerificationService.VerificationRequest();
        request.account_number = 'ACC-001';
        List<CustomerVerificationService.VerificationRequest> requests = new List<CustomerVerificationService.VerificationRequest>{
            request
        };

        Test.startTest();
        List<CustomerVerificationService.VerificationResponse> responses = CustomerVerificationService.verifyCustomer(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            true,
            responses[0].success,
            'Verification should be successful'
        );
        Assert.areEqual(
            'Acme Corporation',
            responses[0].customer_name,
            'Customer name should match mock data'
        );
        Assert.areEqual(
            'jane.doe@acme.com',
            responses[0].customer_email,
            'Customer email should match mock data'
        );
        Assert.areEqual(
            '001MOCK00000000001',
            responses[0].customer_id,
            'Customer ID should match mock data'
        );
    }

    @IsTest
    static void testVerifyCustomerBlankAccountNumber() {
        CustomerVerificationService.VerificationRequest request = new CustomerVerificationService.VerificationRequest();
        request.account_number = '';
        List<CustomerVerificationService.VerificationRequest> requests = new List<CustomerVerificationService.VerificationRequest>{
            request
        };

        Test.startTest();
        List<CustomerVerificationService.VerificationResponse> responses = CustomerVerificationService.verifyCustomer(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            false,
            responses[0].success,
            'Verification should fail for blank account number'
        );
        Assert.areEqual(
            'Account number is required',
            responses[0].error_message,
            'Error message should indicate account number is required'
        );
    }

    @IsTest
    static void testVerifyCustomerNullAccountNumber() {
        CustomerVerificationService.VerificationRequest request = new CustomerVerificationService.VerificationRequest();
        request.account_number = null;
        List<CustomerVerificationService.VerificationRequest> requests = new List<CustomerVerificationService.VerificationRequest>{
            request
        };

        Test.startTest();
        List<CustomerVerificationService.VerificationResponse> responses = CustomerVerificationService.verifyCustomer(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            false,
            responses[0].success,
            'Verification should fail for null account number'
        );
    }

    @IsTest
    static void testVerifyCustomerBulkRequests() {
        List<CustomerVerificationService.VerificationRequest> requests = new List<CustomerVerificationService.VerificationRequest>();

        CustomerVerificationService.VerificationRequest validRequest = new CustomerVerificationService.VerificationRequest();
        validRequest.account_number = 'ACC-001';
        requests.add(validRequest);

        CustomerVerificationService.VerificationRequest blankRequest = new CustomerVerificationService.VerificationRequest();
        blankRequest.account_number = '';
        requests.add(blankRequest);

        Test.startTest();
        List<CustomerVerificationService.VerificationResponse> responses = CustomerVerificationService.verifyCustomer(
            requests
        );
        Test.stopTest();

        Assert.areEqual(2, responses.size(), 'Should return two responses');
        Assert.areEqual(
            true,
            responses[0].success,
            'First request should succeed'
        );
        Assert.areEqual(
            false,
            responses[1].success,
            'Second request should fail'
        );
    }

    @IsTest
    static void testVerifyCustomerWithWhitespace() {
        CustomerVerificationService.VerificationRequest request = new CustomerVerificationService.VerificationRequest();
        request.account_number = '  ACC-001  ';
        List<CustomerVerificationService.VerificationRequest> requests = new List<CustomerVerificationService.VerificationRequest>{
            request
        };

        Test.startTest();
        List<CustomerVerificationService.VerificationResponse> responses = CustomerVerificationService.verifyCustomer(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            true,
            responses[0].success,
            'Verification should succeed with whitespace-padded account number'
        );
    }
}
