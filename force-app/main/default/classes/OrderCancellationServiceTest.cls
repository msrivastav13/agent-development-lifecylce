/**
 * @description Test class for OrderCancellationService
 * Tests order cancellation with validation
 */
@IsTest
private class OrderCancellationServiceTest {
    @IsTest
    static void testCancelOrderSuccess() {
        OrderCancellationService.CancellationRequest request = new OrderCancellationService.CancellationRequest();
        request.order_id = '801MOCK00000000001';
        request.reason = 'Customer requested cancellation';
        List<OrderCancellationService.CancellationRequest> requests = new List<OrderCancellationService.CancellationRequest>{
            request
        };

        Test.startTest();
        List<OrderCancellationService.CancellationResponse> responses = OrderCancellationService.cancelOrder(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            true,
            responses[0].success,
            'Cancellation should be successful'
        );
        Assert.areEqual(
            'ORD-00001',
            responses[0].cancelled_order_number,
            'Cancelled order number should match mock data'
        );
    }

    @IsTest
    static void testCancelOrderBlankOrderId() {
        OrderCancellationService.CancellationRequest request = new OrderCancellationService.CancellationRequest();
        request.order_id = '';
        request.reason = 'Test reason';
        List<OrderCancellationService.CancellationRequest> requests = new List<OrderCancellationService.CancellationRequest>{
            request
        };

        Test.startTest();
        List<OrderCancellationService.CancellationResponse> responses = OrderCancellationService.cancelOrder(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            false,
            responses[0].success,
            'Cancellation should fail for blank order ID'
        );
        Assert.areEqual(
            'Order ID is required',
            responses[0].error_message,
            'Error message should indicate order ID is required'
        );
    }

    @IsTest
    static void testCancelOrderBlankReason() {
        OrderCancellationService.CancellationRequest request = new OrderCancellationService.CancellationRequest();
        request.order_id = '801MOCK00000000001';
        request.reason = '';
        List<OrderCancellationService.CancellationRequest> requests = new List<OrderCancellationService.CancellationRequest>{
            request
        };

        Test.startTest();
        List<OrderCancellationService.CancellationResponse> responses = OrderCancellationService.cancelOrder(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            false,
            responses[0].success,
            'Cancellation should fail for blank reason'
        );
        Assert.areEqual(
            'Cancellation reason is required',
            responses[0].error_message,
            'Error message should indicate reason is required'
        );
    }

    @IsTest
    static void testCancelOrderBulkRequests() {
        List<OrderCancellationService.CancellationRequest> requests = new List<OrderCancellationService.CancellationRequest>();

        OrderCancellationService.CancellationRequest validRequest = new OrderCancellationService.CancellationRequest();
        validRequest.order_id = '801MOCK00000000001';
        validRequest.reason = 'Customer requested';
        requests.add(validRequest);

        OrderCancellationService.CancellationRequest invalidRequest = new OrderCancellationService.CancellationRequest();
        invalidRequest.order_id = '';
        invalidRequest.reason = 'Test';
        requests.add(invalidRequest);

        Test.startTest();
        List<OrderCancellationService.CancellationResponse> responses = OrderCancellationService.cancelOrder(
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
}
