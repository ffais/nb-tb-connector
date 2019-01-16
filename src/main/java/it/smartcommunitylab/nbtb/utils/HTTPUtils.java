package it.smartcommunitylab.nbtb.utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.Base64;

import com.fasterxml.jackson.databind.ObjectMapper;

import it.smartcommunitylab.nbtb.exception.HttpException;

public class HTTPUtils {

	public static String get(String address, String token, String headerKey, String basicAuthUser, String basicAuthPassowrd)
			throws Exception {
		StringBuffer response = new StringBuffer();

		URL url = new URL(address);

		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod("GET");
		conn.setDoOutput(true);
		conn.setDoInput(true);

		conn.setRequestProperty("Accept", "application/json");
		conn.setRequestProperty("Content-Type", "application/json");

		if (Utils.isNotEmpty(basicAuthUser) && Utils.isNotEmpty(basicAuthPassowrd)) {
			String authString = basicAuthUser + ":" + basicAuthPassowrd;
			byte[] authEncBytes = Base64.getEncoder().encode(authString.getBytes());
			String authStringEnc = new String(authEncBytes);
			conn.setRequestProperty("Authorization", "Basic " + authStringEnc);
		}

		if (token != null) {
			conn.setRequestProperty(headerKey, "Bearer " + token);
		}

		// redirection checking
		boolean redirect = false;
		if (conn.getResponseCode() >= 300 && conn.getResponseCode() <= 307 && conn.getResponseCode() != 306) {
			do {
				redirect = false; // reset the value each time
				String loc = conn.getHeaderField("Location"); // get location of
																// the redirect
				if (loc == null) {
					redirect = false;
					continue;
				}
				conn = (HttpURLConnection) new URL(loc).openConnection();
				conn.setRequestProperty("Accept", "application/json");
				conn.setRequestProperty("Content-Type", "application/json");
				
				if (Utils.isNotEmpty(basicAuthUser) && Utils.isNotEmpty(basicAuthPassowrd)) {
					String authString = basicAuthUser + ":" + basicAuthPassowrd;
					byte[] authEncBytes = Base64.getEncoder().encode(authString.getBytes());
					String authStringEnc = new String(authEncBytes);
					conn.setRequestProperty("Authorization", "Basic " + authStringEnc);
				}
				
				if (conn.getResponseCode() != 500) { // 500 = fail
					if (conn.getResponseCode() >= 300 && conn.getResponseCode() <= 307
							&& conn.getResponseCode() != 306) {
						redirect = true;
					}
					// I do special handling here with cookies
					// if you need to bring a session cookie over to the
					// redirected page, this is the place to grab that info
				}
			} while (redirect);
		}

		if (conn.getResponseCode() >= 400) {
			throw new HttpException(conn.getResponseCode(), 
					"Failed HTTP error for " + address + ":" + conn.getResponseCode());
		}

		BufferedReader br = new BufferedReader(
				new InputStreamReader((conn.getInputStream()), Charset.defaultCharset()));

		String output = null;
		while ((output = br.readLine()) != null) {
			response.append(output);
		}

		conn.disconnect();

		String res = new String(response.toString().getBytes(), Charset.forName("UTF-8"));

		return res;
	}
	
	public static String post(String address, Object content, String token, String headerKey,
			String basicAuthUser, String basicAuthPassowrd) throws Exception {
		StringBuffer response = new StringBuffer();

		URL url = new URL(address);

		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod("POST");
		conn.setDoOutput(true);
		conn.setDoInput(true);

		conn.setRequestProperty("Accept", "application/json");
		conn.setRequestProperty("Content-Type", "application/json");
		
		if(Utils.isNotEmpty(basicAuthUser) && Utils.isNotEmpty(basicAuthPassowrd)) {
			String authString = basicAuthUser + ":" + basicAuthPassowrd;
			byte[] authEncBytes = Base64.getEncoder().encode(authString.getBytes());
			String authStringEnc = new String(authEncBytes);
			conn.setRequestProperty("Authorization", "Basic " + authStringEnc);
		}
		
		if (token != null) {
			conn.setRequestProperty(headerKey, "Bearer " + token);
		}

		String contentString = null;
		if(content instanceof String) {
			contentString = (String) content;
		} else {
			ObjectMapper mapper = new ObjectMapper();
			contentString = mapper.writeValueAsString(content);
		}
		
		OutputStream out = conn.getOutputStream();
		Writer writer = new OutputStreamWriter(out, "UTF-8");
		writer.write(contentString);
		writer.close();
		out.close();		
		
		if (conn.getResponseCode() >= 300) {
			throw new HttpException(conn.getResponseCode(), 
					"Failed HTTP error for " + address + ":" + conn.getResponseCode());
		}

		BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream()), Charset.defaultCharset()));

		String output = null;
		while ((output = br.readLine()) != null) {
			response.append(output);
		}

		conn.disconnect();

		String res = new String(response.toString().getBytes(), Charset.forName("UTF-8"));
	
		return res;
	}	
	
}
