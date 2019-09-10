public abstract class AbstractDataService {
    public sObject getSingleRecord(List<sObject> objects) {
        Integer count = objects.size();
        if (count == 0) {
            throw new NoRecordFoundException('No record found');
        }
        if (count > 1) {
            throw new TooManyRecordFoundException('Too many records, expected single record');
        }
        return objects.get(0);
    }

    public class NoRecordFoundException extends Exception {}
    public class TooManyRecordFoundException extends Exception {}
}
