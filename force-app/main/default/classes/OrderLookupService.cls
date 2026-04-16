/**
 * @description Invocable service for retrieving orders associated with a customer.
 * Returns a formatted summary of all orders for the verified customer.
 */
public with sharing class OrderLookupService {
    /**
     * @description Input class for order lookup request
     */
    public class OrderLookupRequest {
        @InvocableVariable(
            label='Customer ID'
            description='The Salesforce record ID of the customer to look up orders for'
            required=true
        )
        public String customer_id;
    }

    /**
     * @description Output class for order lookup response
     */
    public class OrderLookupResponse {
        @InvocableVariable(
            label='Success'
            description='Indicates if the order lookup was successful'
        )
        public Boolean success;

        @InvocableVariable(
            label='Order Count'
            description='Total number of orders found for the customer'
        )
        public Integer order_count;

        @InvocableVariable(
            label='Order Summary'
            description='Formatted summary of all orders for the customer'
        )
        public String order_summary;

        @InvocableVariable(
            label='Error Message'
            description='Error message if the lookup failed'
        )
        public String error_message;
    }

    /**
     * @description Retrieves all orders for a given customer ID
     * @param requests List of OrderLookupRequest objects
     * @return List of OrderLookupResponse objects with order data
     */
    @InvocableMethod(
        label='Get Customer Orders'
        description='Retrieves all orders for a customer and returns a formatted summary'
    )
    public static List<OrderLookupResponse> getOrders(
        List<OrderLookupRequest> requests
    ) {
        List<OrderLookupResponse> responses = new List<OrderLookupResponse>();

        for (OrderLookupRequest req : requests) {
            OrderLookupResponse response = new OrderLookupResponse();

            // Mock implementation - replace with actual SOQL lookup in your custom code
            if (String.isNotBlank(req.customer_id)) {
                response.success = true;
                response.order_count = 3;
                response.order_summary =
                    'Order ORD-00001 | Status: Draft | Amount: $1,200.00 | Date: 2025-01-15\n' +
                    'Order ORD-00002 | Status: Activated | Amount: $850.00 | Date: 2025-02-20\n' +
                    'Order ORD-00003 | Status: Draft | Amount: $2,400.00 | Date: 2025-03-10';
            } else {
                response.success = false;
                response.order_count = 0;
                response.error_message = 'Customer ID is required';
            }

            responses.add(response);
        }

        return responses;
    }
}
