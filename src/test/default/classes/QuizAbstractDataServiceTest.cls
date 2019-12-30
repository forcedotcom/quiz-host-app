@isTest(isParallel=true)
public class QuizAbstractDataServiceTest {
    private final static String TEST_OBJECT_NAME = 'SampleObject';
    private final static String TEST_RECORD_NAME = 'Sample name';

    @isTest
    static void getSingleRecord_works() {
        QuizAbstractDataService service = new QuizAbstractDataService();
        List<sObject> objects = new List<sObject>();
        objects.add(new Account(Name = TEST_RECORD_NAME));

        Account account = (Account) service.getSingleRecord(
            TEST_OBJECT_NAME,
            objects
        );

        System.assertEquals(TEST_RECORD_NAME, account.Name);
    }

    @isTest
    static void getSingleRecord_failsWhenNoRecords() {
        QuizAbstractDataService service = new QuizAbstractDataService();
        List<sObject> objects = new List<sObject>();

        try {
            service.getSingleRecord(TEST_OBJECT_NAME, objects);
            // expect to fail
            System.assert(false);
        } catch (QuizAbstractDataService.NoRecordFoundException e) {
            System.assert(e.getMessage().contains(TEST_OBJECT_NAME));
        }
    }

    @isTest
    static void getSingleRecord_failsWhenTooManyRecords() {
        QuizAbstractDataService service = new QuizAbstractDataService();
        List<sObject> objects = new List<sObject>();
        objects.add(new Account(Name = TEST_RECORD_NAME + '1'));
        objects.add(new Account(Name = TEST_RECORD_NAME + '2'));

        try {
            service.getSingleRecord(TEST_OBJECT_NAME, objects);
            // expect to fail
            System.assert(false);
        } catch (QuizAbstractDataService.TooManyRecordFoundException e) {
            System.assert(e.getMessage().contains(TEST_OBJECT_NAME));
        }
    }
}
