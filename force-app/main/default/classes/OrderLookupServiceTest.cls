/**
 * @description Test class for OrderLookupService
 * Tests order retrieval by customer ID
 */
@IsTest
private class OrderLookupServiceTest {
    @IsTest
    static void testGetOrdersSuccess() {
        OrderLookupService.OrderLookupRequest request = new OrderLookupService.OrderLookupRequest();
        request.customer_id = '001MOCK00000000001';
        List<OrderLookupService.OrderLookupRequest> requests = new List<OrderLookupService.OrderLookupRequest>{
            request
        };

        Test.startTest();
        List<OrderLookupService.OrderLookupResponse> responses = OrderLookupService.getOrders(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            true,
            responses[0].success,
            'Order lookup should be successful'
        );
        Assert.areEqual(
            3,
            responses[0].order_count,
            'Should return three mock orders'
        );
        Assert.isNotNull(
            responses[0].order_summary,
            'Order summary should not be null'
        );
        Assert.isTrue(
            responses[0].order_summary.contains('ORD-00001'),
            'Order summary should contain mock order number'
        );
    }

    @IsTest
    static void testGetOrdersBlankCustomerId() {
        OrderLookupService.OrderLookupRequest request = new OrderLookupService.OrderLookupRequest();
        request.customer_id = '';
        List<OrderLookupService.OrderLookupRequest> requests = new List<OrderLookupService.OrderLookupRequest>{
            request
        };

        Test.startTest();
        List<OrderLookupService.OrderLookupResponse> responses = OrderLookupService.getOrders(
            requests
        );
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            false,
            responses[0].success,
            'Lookup should fail for blank customer ID'
        );
        Assert.areEqual(
            'Customer ID is required',
            responses[0].error_message,
            'Error message should indicate customer ID is required'
        );
    }

    @IsTest
    static void testGetOrdersBulkRequests() {
        List<OrderLookupService.OrderLookupRequest> requests = new List<OrderLookupService.OrderLookupRequest>();

        OrderLookupService.OrderLookupRequest validRequest = new OrderLookupService.OrderLookupRequest();
        validRequest.customer_id = '001MOCK00000000001';
        requests.add(validRequest);

        OrderLookupService.OrderLookupRequest blankRequest = new OrderLookupService.OrderLookupRequest();
        blankRequest.customer_id = '';
        requests.add(blankRequest);

        Test.startTest();
        List<OrderLookupService.OrderLookupResponse> responses = OrderLookupService.getOrders(
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
