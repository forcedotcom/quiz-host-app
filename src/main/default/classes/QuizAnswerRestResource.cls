@RestResource(urlMapping='/quiz/answers')
global abstract class QuizAnswerRestResource {
    private static final QuizAnswerService answerService = new QuizAnswerService();

    @HttpPost
    global static void submitAnswer(Id playerId, String answer) {
        Object responseData;
        Integer statusCode;
        try {
            Quiz_Answer__c answerRecord = answerService.create(
                playerId,
                answer
            );
            responseData = new QuizAnswer(answerRecord);
            statusCode = 200;
        } catch (QuizAnswerService.InvalidPhaseException e) {
            responseData = new ErrorMessage(
                'Answer not saved: you answered too late!'
            );
            statusCode = 400;
        } catch (QuizAnswerService.DuplicateAnswerException e) {
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
