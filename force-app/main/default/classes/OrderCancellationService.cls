/**
 * @description Invocable service for cancelling customer orders.
 * Validates the order exists and is in a cancellable state before processing.
 */
public with sharing class OrderCancellationService {
    /**
     * @description Input class for order cancellation request
     */
    public class CancellationRequest {
        @InvocableVariable(
            label='Order ID'
            description='The Salesforce record ID of the order to cancel'
            required=true
        )
        public String order_id;

        @InvocableVariable(
            label='Reason'
            description='The reason for cancelling the order'
            required=true
        )
        public String reason;
    }

    /**
     * @description Output class for order cancellation response
     */
    public class CancellationResponse {
        @InvocableVariable(
            label='Success'
            description='Indicates if the cancellation was successful'
        )
        public Boolean success;

        @InvocableVariable(
            label='Cancelled Order Number'
            description='The order number of the cancelled order'
        )
        public String cancelled_order_number;

        @InvocableVariable(
            label='Error Message'
            description='Error message if cancellation failed'
        )
        public String error_message;
    }

    /**
     * @description Cancels an order by updating its status
     * @param requests List of CancellationRequest objects
     * @return List of CancellationResponse objects with results
     */
    @InvocableMethod(
        label='Cancel Order'
        description='Cancels a customer order after validating it is in a cancellable state'
    )
    public static List<CancellationResponse> cancelOrder(
        List<CancellationRequest> requests
    ) {
        List<CancellationResponse> responses = new List<CancellationResponse>();

        for (CancellationRequest req : requests) {
            CancellationResponse response = new CancellationResponse();

            if (String.isBlank(req.order_id)) {
                response.success = false;
                response.error_message = 'Order ID is required';
                responses.add(response);
                continue;
            }

            if (String.isBlank(req.reason)) {
                response.success = false;
                response.error_message = 'Cancellation reason is required';
                responses.add(response);
                continue;
            }

            // Mock implementation - replace with actual SOQL/DML in your custom code
            response.success = true;
            response.cancelled_order_number = 'ORD-00001';
            responses.add(response);
        }

        return responses;
    }
}
