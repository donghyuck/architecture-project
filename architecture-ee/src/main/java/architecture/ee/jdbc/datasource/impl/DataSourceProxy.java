/*
 * Copyright 2012, 2013 Donghyuck, Son
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package architecture.ee.jdbc.datasource.impl;

import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLFeatureNotSupportedException;
import java.util.logging.Logger;

import javax.sql.DataSource;

public class DataSourceProxy implements DataSource {

    private DataSource dataSource;

    public DataSourceProxy(DataSource dataSource) {
	this.dataSource = dataSource;
    }

    public Connection getConnection() throws SQLException {
	return dataSource.getConnection();
    }

    public Connection getConnection(String username, String password) throws SQLException {
	return dataSource.getConnection(username, password);
    }

    public PrintWriter getLogWriter() throws SQLException {
	return dataSource.getLogWriter();
    }

    public void setLogWriter(PrintWriter out) throws SQLException {
	dataSource.setLogWriter(out);
    }

    public void setLoginTimeout(int seconds) throws SQLException {
	dataSource.setLoginTimeout(seconds);
    }

    public int getLoginTimeout() throws SQLException {
	return dataSource.getLoginTimeout();
    }

    @Override
    public <T> T unwrap(Class<T> iface) throws SQLException {
	// TODO 자동 생성된 메소드 스텁
	return dataSource.unwrap(iface);
    }

    @Override
    public boolean isWrapperFor(Class<?> iface) throws SQLException {
	return dataSource.isWrapperFor(iface);
    }

    @Override
    public Logger getParentLogger() throws SQLFeatureNotSupportedException {

	return null;
    }

}
