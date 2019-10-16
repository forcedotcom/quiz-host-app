@RestResource(urlMapping='/quiz/answers')
global abstract class AnswerRestResource {
    private static AnswerService answerService = new AnswerService();

    @HttpPost
    global static void submitAnswer(Id playerId, String answer) {
        Object responseData;
        Integer statusCode;
        try {
            responseData = answerService.create(playerId, answer);
            statusCode = 200;
        } catch (AnswerService.InvalidPhaseException e) {
            responseData = new ErrorMessage(
                'Answer not saved: invalid quiz phase'
            );
            statusCode = 400;
        } catch (AnswerService.DuplicateAnswerException e) {
            responseData = new ErrorMessage(
                'Answer not saved: found duplicate answer'
            );
            statusCode = 400;
        } catch (Exception e) {
            responseData = new ErrorMessage('Answer not saved');
            statusCode = 500;
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
