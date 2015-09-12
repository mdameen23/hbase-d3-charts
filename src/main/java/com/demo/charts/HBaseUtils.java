package com.demo.charts;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.util.Bytes;

import java.util.LinkedHashMap;

public class HBaseUtils {

	private Configuration hConfig;
    
    public HBaseUtils() {
        try {
            hConfig = HBaseConfiguration.create();
            hConfig.set("hbase.zookeeper.quorum", "localhost");
            hConfig.set("hbase.zookeeper.property.clientPort", "2181");
        } catch (Exception ex) {
            
        }
    }
    
    public LinkedHashMap<String, String> scanTable(String tableName, String colF, String colN) {
    	LinkedHashMap<String, String> retVal = new LinkedHashMap<String, String>();
    	
        try {
            HTable theTable = new HTable(hConfig, tableName);
            Scan scan = new Scan();
            scan.addColumn(Bytes.toBytes(colF), Bytes.toBytes(colN));
            ResultScanner rScanner = theTable.getScanner(scan);
            for (Result result = rScanner.next(); (result != null); result = rScanner.next()) {
                byte[] rowB = result.getRow();
                String strRow = Bytes.toString(rowB);
                byte[] resB = result.getValue(Bytes.toBytes(colF), Bytes.toBytes(colN));
                String strVal = Long.toString(Bytes.toLong(resB));
                
                retVal.put(strRow, strVal);
            }
            theTable.close();
            rScanner.close();
        } catch (Exception ex) {

        }   
        return retVal;
    }
}
