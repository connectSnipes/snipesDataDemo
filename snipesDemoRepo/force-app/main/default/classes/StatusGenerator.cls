//Author -Yashas S K (yashas_sk@perfaware.com)
public class StatusGenerator {
    // Method to generate a random status (success or failed)
    @InvocableMethod(label = 'Status Generator')
    public static List<Output> generateRandomStatus() {
        Integer randomCode = Math.round(Math.random());
        String status = (randomCode == 1) ? 'Success' : 'Failed';
 
        List<Output> outputList = new List<Output>();
        Output newOutput = new Output();
        newOutput.response = status;
        outputList.add(newOutput);
        return outputList;
    }
  
	
    public class Output{
        @InvocableVariable
        public String response;
    }
}