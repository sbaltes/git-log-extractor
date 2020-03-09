import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GitLogFilter {
    public static void main(String[] args) {
        Pattern commitHashPattern = Pattern.compile("^commit ([0-9a-f]{40})$");
        Pattern urlLinePattern = Pattern.compile("^.*(https?://(?:www\\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_+.~#?&/=]*)).*$");

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(System.in))) {
            String line;
            String commitHash = "";
            while ((line = reader.readLine()) != null) {
                Matcher commitHashMatcher = commitHashPattern.matcher(line);
                if (commitHashMatcher.matches()) {
                    commitHash = commitHashMatcher.group(1);
                    continue;
                }
                Matcher urlLineMatcher = urlLinePattern.matcher(line);
                if (urlLineMatcher.matches()) {
                    System.out.println(commitHash + "," + urlLineMatcher.group(1));
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
