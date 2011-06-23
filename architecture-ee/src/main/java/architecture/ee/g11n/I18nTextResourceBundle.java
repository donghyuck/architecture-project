package architecture.ee.g11n;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.ListResourceBundle;
import java.util.Locale;
import java.util.Set;


public class I18nTextResourceBundle extends ListResourceBundle {

    private Object contents[][];
    private Locale locale;
    public final Set<String> keySet;
    
    public I18nTextResourceBundle(Locale locale, List<String[]> keyValues)
    {
        this.locale = locale;
        this.contents = new Object[keyValues.size()][2];
        Set<String> tempKeySet = new HashSet<String>();
        int index = 0;        
        for( String[] keyValue : keyValues ){
            this.contents[index][0] = keyValue[0];
            tempKeySet.add(keyValue[0]);
            this.contents[index][1] = keyValue[1];
            index++;
        }
        this.keySet = Collections.unmodifiableSet(tempKeySet);
    }

    public Object[][] getContents()
    {
        return contents;
    }

    public Locale getLocale() {
        return locale;
    }
}
