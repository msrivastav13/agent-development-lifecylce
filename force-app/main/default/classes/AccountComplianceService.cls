/**
 * @description Invocable service for checking account compliance status.
 * Used deterministically by the Order Management agent after customer verification
 * to validate account standing before allowing order operations.
 */
public with sharing class AccountComplianceService {
    /**
     * @description Input class for compliance check request
     */
    public class ComplianceRequest {
        @InvocableVariable(
            label='Customer ID'
            description='The Salesforce record ID of the verified customer'
            required=true
        )
        public String customer_id;
    }

    /**
     * @description Output class for compliance check response
     */
    public class ComplianceResponse {
        @InvocableVariable(
            label='Is Compliant'
            description='Whether the account is in good standing'
        )
        public Boolean is_compliant;

        @InvocableVariable(
            label='Compliance Status'
            description='Human-readable compliance status message'
        )
        public String compliance_status;

        @InvocableVariable(
            label='Risk Level'
            description='Account risk level: Low, Medium, or High'
        )
        public String risk_level;
    }

    /**
     * @description Checks account compliance and standing for a verified customer
     * @param requests List of ComplianceRequest objects
     * @return List of ComplianceResponse objects with compliance data
     */
    @InvocableMethod(
        label='Check Account Compliance'
        description='Validates account compliance and standing for a verified customer'
    )
    public static List<ComplianceResponse> checkCompliance(
        List<ComplianceRequest> requests
    ) {
        List<ComplianceResponse> responses = new List<ComplianceResponse>();

        for (ComplianceRequest req : requests) {
            ComplianceResponse response = new ComplianceResponse();

            // Mock implementation - replace with actual compliance logic
            if (String.isNotBlank(req.customer_id)) {
                response.is_compliant = true;
                response.compliance_status = 'Account is in good standing';
                response.risk_level = 'Low';
            } else {
                response.is_compliant = false;
                response.compliance_status = 'Unable to verify account compliance';
                response.risk_level = 'High';
            }

            responses.add(response);
        }

        return responses;
    }
}
