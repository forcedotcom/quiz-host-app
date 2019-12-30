@RestResource(urlMapping='/quiz/player/stats')
global abstract class QuizPlayerStatsRestResource {
    private static final QuizAnswerService answerService = new QuizAnswerService();

    @HttpGet
    global static void getPlayerStats() {
        RestRequest request = RestContext.request;
        String playerId = request.params.get('id');

        Object responseData;
        Integer statusCode;
        if (String.isBlank(playerId)) {
            responseData = new ErrorMessage('Missing id parameter');
            statusCode = 400;
        } else {
            try {
                responseData = answerService.getPlayerAnswerStats(playerId);
                statusCode = 200;
            } catch (QuizAbstractDataService.NoRecordFoundException e) {
                responseData = new ErrorMessage(e.getMessage());
                statusCode = 400;
            }
        }

        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(JSON.serialize(responseData));
    }

    global class ErrorMessage {
        ErrorMessage(String message) {
            this.message = message;
        }
        String message;
    }
}
