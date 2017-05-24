package com.mmikhail.demo.ide;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import java.io.IOException;
import java.io.StringReader;

import javax.jws.WebMethod;
import javax.jws.WebService;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;

import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.FormattingResults;
import org.apache.fop.apps.MimeConstants;
import org.apache.fop.apps.PageSequenceResults;

@WebService(targetNamespace = "http://mmikhail.com/demo/ide/")
public class fo2Pdf {
    private final FopFactory fopFactory;
        
    public fo2Pdf() {
        super();
        fopFactory = FopFactory.newInstance(new File(".").toURI());
    }

    /**
     * @param fo    Accepts Apache FO XML document and produces PDF document
     * @return      PDF document as byte[] 
     */
    public byte[] makePDF(String fo) {
    ByteArrayOutputStream result = new ByteArrayOutputStream();
            try {
                FOUserAgent foUserAgent = fopFactory.newFOUserAgent();
                // configure foUserAgent as desired

                // Setup output stream.  Note: Using BufferedOutputStream
                // for performance reasons (helpful with FileOutputStreams).
                
                
                // Construct fop with desired output format
                Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, foUserAgent,result);

                // Setup JAXP using identity transformer
                TransformerFactory factory = TransformerFactory.newInstance();
                Transformer transformer = factory.newTransformer(); // identity transformer

                // Setup input stream
                Source src = new StreamSource(new StringReader(fo));

                // Resulting SAX events (the generated FO) must be piped through to FOP
                Result res = new SAXResult(fop.getDefaultHandler());

                // Start XSLT transformation and FOP processing
                transformer.transform(src, res);
                // Result processing
                FormattingResults foResults = fop.getResults();
                java.util.List pageSequences = foResults.getPageSequences();
                for (java.util.Iterator it = pageSequences.iterator(); it.hasNext();) {
                    PageSequenceResults pageSequenceResults = (PageSequenceResults)it.next();
                    System.out.println("PageSequence "
                            + (String.valueOf(pageSequenceResults.getID()).length() > 0
                                    ? pageSequenceResults.getID() : "<no id>")
                            + " generated " + pageSequenceResults.getPageCount() + " pages.");
                }
                System.out.println("Generated " + foResults.getPageCount() + " pages in total.");

            } catch (Exception e) {
                e.printStackTrace(System.err);
                System.exit(-1);
            } finally {
                return result.toByteArray();
            }

}

    /**
     * @param args
     */
    @WebMethod(exclude = true)
    public static void main(String[] args) {
        String sfo = "<!-- $Id$ -->\n" + 
        "<fo:root xmlns:fo=\"http://www.w3.org/1999/XSL/Format\">\n" + 
        "  <fo:layout-master-set>\n" + 
        "    <fo:simple-page-master master-name=\"simpleA4\" page-height=\"29.7cm\" page-width=\"21cm\" margin-top=\"2cm\" margin-bottom=\"2cm\" margin-left=\"2cm\" margin-right=\"2cm\">\n" + 
        "      <fo:region-body/>\n" + 
        "    </fo:simple-page-master>\n" + 
        "  </fo:layout-master-set>\n" + 
        "  <fo:page-sequence master-reference=\"simpleA4\">\n" + 
        "    <fo:flow flow-name=\"xsl-region-body\">\n" + 
        "      <fo:block>Hello World!</fo:block>\n" + 
        "    </fo:flow>\n" + 
        "  </fo:page-sequence>\n" + 
        "</fo:root>\n";
            try {
        fo2Pdf fo2Pdf = new fo2Pdf();
        byte rs[] = fo2Pdf.makePDF(sfo);
        FileOutputStream fos = new FileOutputStream("C:/Temp/hello-fo.pdf");
      
            fos.write(rs);
            fos.close();
        } catch (IOException e) {
                e.printStackTrace(System.err);
        }
    }
}
