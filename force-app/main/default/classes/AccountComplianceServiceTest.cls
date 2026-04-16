/**
 * @description Test class for AccountComplianceService
 * Tests account compliance checking for verified customers
 */
@IsTest
private class AccountComplianceServiceTest {
    @IsTest
    static void testCheckComplianceSuccess() {
        AccountComplianceService.ComplianceRequest request = new AccountComplianceService.ComplianceRequest();
        request.customer_id = '001MOCK00000000001';
        List<AccountComplianceService.ComplianceRequest> requests = new List<AccountComplianceService.ComplianceRequest>{
            request
        };

        Test.startTest();
        List<AccountComplianceService.ComplianceResponse> responses = AccountComplianceService.checkCompliance(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            true,
            responses[0].is_compliant,
            'Account should be compliant'
        );
        Assert.areEqual(
            'Account is in good standing',
            responses[0].compliance_status,
            'Compliance status should indicate good standing'
        );
        Assert.areEqual(
            'Low',
            responses[0].risk_level,
            'Risk level should be Low'
        );
    }

    @IsTest
    static void testCheckComplianceBlankCustomerId() {
        AccountComplianceService.ComplianceRequest request = new AccountComplianceService.ComplianceRequest();
        request.customer_id = '';
        List<AccountComplianceService.ComplianceRequest> requests = new List<AccountComplianceService.ComplianceRequest>{
            request
        };

        Test.startTest();
        List<AccountComplianceService.ComplianceResponse> responses = AccountComplianceService.checkCompliance(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            false,
            responses[0].is_compliant,
            'Account should not be compliant for blank ID'
        );
        Assert.areEqual(
            'High',
            responses[0].risk_level,
            'Risk level should be High for blank ID'
        );
    }

    @IsTest
    static void testCheckComplianceNullCustomerId() {
        AccountComplianceService.ComplianceRequest request = new AccountComplianceService.ComplianceRequest();
        request.customer_id = null;
        List<AccountComplianceService.ComplianceRequest> requests = new List<AccountComplianceService.ComplianceRequest>{
            request
        };

        Test.startTest();
        List<AccountComplianceService.ComplianceResponse> responses = AccountComplianceService.checkCompliance(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            false,
            responses[0].is_compliant,
            'Account should not be compliant for null ID'
        );
    }

    @IsTest
    static void testCheckComplianceBulkRequests() {
        List<AccountComplianceService.ComplianceRequest> requests = new List<AccountComplianceService.ComplianceRequest>();

        AccountComplianceService.ComplianceRequest validRequest = new AccountComplianceService.ComplianceRequest();
        validRequest.customer_id = '001MOCK00000000001';
        requests.add(validRequest);

        AccountComplianceService.ComplianceRequest blankRequest = new AccountComplianceService.ComplianceRequest();
        blankRequest.customer_id = '';
        requests.add(blankRequest);

        Test.startTest();
        List<AccountComplianceService.ComplianceResponse> responses = AccountComplianceService.checkCompliance(
            requests
        );
        Test.stopTest();

        Assert.areEqual(2, responses.size(), 'Should return two responses');
        Assert.areEqual(
            true,
            responses[0].is_compliant,
            'First request should be compliant'
        );
        Assert.areEqual(
            false,
            responses[1].is_compliant,
            'Second request should not be compliant'
        );
    }
}
