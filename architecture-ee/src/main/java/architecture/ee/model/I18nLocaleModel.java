package architecture.ee.model;

import architecture.common.model.ModelObject;
import architecture.ee.i18n.I18nLocale;


/**
 * @author donghyuck
 */
public interface I18nLocaleModel extends ModelObject<I18nLocale> {

    /**
	 * @return
	 */
    public abstract long getLocaleId();

    /**
	 * @param  id
	 */
    public abstract void setLocaleId(long id) ;

    /**
	 * @return
	 */
    public abstract String getLanguage() ;

    /**
	 * @param  language
	 */
    public abstract void setLanguage(String language) ;

    /**
	 * @return
	 */
    public abstract String getCountry();

    /**
	 * @param  country
	 */
    public abstract void setCountry(String country);

    /**
	 * @return
	 */
    public abstract String getEncoding();

    /**
	 * @param  encoding
	 */
    public abstract void setEncoding(String encoding);

    /**
	 * @return
	 */
    public abstract String getVariant() ;

    /**
	 * @param  variant
	 */
    public abstract void setVariant(String variant);

    /**
     * 
     * @return
     */
    public abstract java.util.Locale toJavaLocale();
    
}
