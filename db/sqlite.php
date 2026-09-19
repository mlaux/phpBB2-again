<?php
/***************************************************************************
 *                                 sqlite.php
 *                            -------------------
 *   SQLite3 layer for phpBB 2.0.x on PHP 8.
 *
 *   $dbname is the path to the database file (relative to the phpBB root
 *   if not absolute). $dbhost, $dbuser and $dbpasswd are ignored.
 *
 *   Result sets are fully buffered so that sql_numrows() and
 *   sql_rowseek() work like they did with the mysql extension.
 *
 ***************************************************************************/

/***************************************************************************
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 ***************************************************************************/

if(!defined("SQL_LAYER"))
{

define("SQL_LAYER","sqlite");

class sqlite_result
{
	var $rows = array();
	var $names = array();
	var $types = array();
	var $pos = 0;
}

class sql_db
{
	var $db_connect_id;
	var $query_result;
	var $row = array();
	var $rowset = array();
	var $num_queries = 0;
	var $dbname;
	var $in_transaction = false;
	var $error_message = '';
	var $error_code = 0;

	function __construct($sqlserver, $sqluser, $sqlpassword, $database, $persistency = true)
	{
		global $phpbb_root_path;

		$this->dbname = $database;
		if ($database != ':memory:' && $database[0] != '/' && isset($phpbb_root_path))
		{
			$this->dbname = $phpbb_root_path . $database;
		}

		try
		{
			$this->db_connect_id = new SQLite3($this->dbname);
		}
		catch (Exception $e)
		{
			$this->db_connect_id = false;
			$this->error_message = $e->getMessage();
			return;
		}

		$this->db_connect_id->busyTimeout(10000);
		@$this->db_connect_id->exec('PRAGMA journal_mode = WAL');
		@$this->db_connect_id->exec('PRAGMA synchronous = NORMAL');
	}

	function sql_close()
	{
		if (!$this->db_connect_id)
		{
			return false;
		}
		if ($this->in_transaction)
		{
			@$this->db_connect_id->exec('COMMIT');
			$this->in_transaction = false;
		}
		$this->db_connect_id->close();
		$this->db_connect_id = false;
		return true;
	}

	//
	// phpBB escapes string data with addslashes() (MySQL style). SQLite only
	// understands doubled single quotes, so undo the backslash escapes here.
	//
	function _convert_escapes($query)
	{
		if (strpos($query, '\\') === false)
		{
			return $query;
		}

		$out = '';
		$len = strlen($query);
		for ($k = 0; $k < $len; $k++)
		{
			$c = $query[$k];
			if ($c != '\\' || $k + 1 >= $len)
			{
				$out .= $c;
				continue;
			}
			$k++;
			$n = $query[$k];
			if ($n == "'")
			{
				$out .= "''";
			}
			else if ($n == '0')
			{
				// NUL bytes cannot be stored in a SQL literal, drop them
			}
			else
			{
				$out .= $n;
			}
		}
		return $out;
	}

	function sql_query($query = "", $transaction = FALSE)
	{
		unset($this->query_result);
		$this->query_result = false;

		if (!$this->db_connect_id)
		{
			return false;
		}

		if ($transaction == BEGIN_TRANSACTION && !$this->in_transaction)
		{
			if (@$this->db_connect_id->exec('BEGIN'))
			{
				$this->in_transaction = true;
			}
		}

		if ($query != "")
		{
			$this->num_queries++;
			$query = $this->_convert_escapes($query);
			$this->query_result = $this->_run($query);
		}

		if ($transaction == END_TRANSACTION && $this->in_transaction)
		{
			$this->in_transaction = false;
			if (!$this->query_result || !@$this->db_connect_id->exec('COMMIT'))
			{
				@$this->db_connect_id->exec('ROLLBACK');
				return false;
			}
			return true;
		}

		if (!$this->query_result)
		{
			if ($this->in_transaction)
			{
				@$this->db_connect_id->exec('ROLLBACK');
				$this->in_transaction = false;
			}
			return false;
		}

		$key = spl_object_id($this->query_result);
		unset($this->row[$key]);
		unset($this->rowset[$key]);
		return $this->query_result;
	}

	function _run($query)
	{
		$this->error_message = '';
		$this->error_code = 0;

		$is_select = preg_match('#^\s*(SELECT|PRAGMA|EXPLAIN)\b#i', $query);
		if (!$is_select)
		{
			$ok = @$this->db_connect_id->exec($query);
			if (!$ok)
			{
				$this->error_message = $this->db_connect_id->lastErrorMsg();
				$this->error_code = $this->db_connect_id->lastErrorCode();
				return false;
			}
			return new sqlite_result();
		}

		$res = @$this->db_connect_id->query($query);
		if (!$res)
		{
			$this->error_message = $this->db_connect_id->lastErrorMsg();
			$this->error_code = $this->db_connect_id->lastErrorCode();
			return false;
		}

		$result = new sqlite_result();
		$ncols = $res->numColumns();
		for ($k = 0; $k < $ncols; $k++)
		{
			$result->names[$k] = $res->columnName($k);
			$result->types[$k] = $res->columnType($k);
		}
		while ($row = $res->fetchArray(SQLITE3_BOTH))
		{
			$result->rows[] = $row;
		}
		$res->finalize();
		return $result;
	}

	function _result($query_id)
	{
		if (!$query_id)
		{
			$query_id = $this->query_result;
		}
		return ($query_id instanceof sqlite_result) ? $query_id : false;
	}

	function sql_numrows($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		return $query_id ? count($query_id->rows) : false;
	}

	function sql_affectedrows()
	{
		return $this->db_connect_id ? $this->db_connect_id->changes() : false;
	}

	function sql_numfields($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		return $query_id ? count($query_id->names) : false;
	}

	function sql_fieldname($offset, $query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id || !isset($query_id->names[$offset]))
		{
			return false;
		}
		return $query_id->names[$offset];
	}

	function sql_fieldtype($offset, $query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id || !isset($query_id->types[$offset]))
		{
			return false;
		}
		switch ($query_id->types[$offset])
		{
			case SQLITE3_INTEGER:
				return 'int';
			case SQLITE3_FLOAT:
				return 'real';
			case SQLITE3_BLOB:
				return 'blob';
			default:
				return 'string';
		}
	}

	function sql_fetchrow($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id)
		{
			return false;
		}
		$key = spl_object_id($query_id);
		if ($query_id->pos >= count($query_id->rows))
		{
			$this->row[$key] = false;
			return false;
		}
		$this->row[$key] = $query_id->rows[$query_id->pos++];
		return $this->row[$key];
	}

	function sql_fetchrowset($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id)
		{
			return false;
		}
		$key = spl_object_id($query_id);
		unset($this->rowset[$key]);
		unset($this->row[$key]);
		$result = array();
		while ($this->rowset[$key] = $this->sql_fetchrow($query_id))
		{
			$result[] = $this->rowset[$key];
		}
		return $result;
	}

	function sql_fetchfield($field, $rownum = -1, $query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id)
		{
			return false;
		}
		$key = spl_object_id($query_id);
		if ($rownum > -1)
		{
			return isset($query_id->rows[$rownum][$field]) ? $query_id->rows[$rownum][$field] : false;
		}
		if (empty($this->row[$key]) && empty($this->rowset[$key]))
		{
			if (!$this->sql_fetchrow($query_id))
			{
				return false;
			}
			return $this->row[$key][$field];
		}
		if (!empty($this->rowset[$key]))
		{
			return $this->rowset[$key][0][$field];
		}
		return $this->row[$key][$field];
	}

	function sql_rowseek($rownum, $query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id || $rownum < 0 || $rownum > count($query_id->rows))
		{
			return false;
		}
		$query_id->pos = $rownum;
		return true;
	}

	function sql_nextid()
	{
		return $this->db_connect_id ? $this->db_connect_id->lastInsertRowID() : false;
	}

	function sql_freeresult($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id)
		{
			return false;
		}
		$key = spl_object_id($query_id);
		unset($this->row[$key]);
		unset($this->rowset[$key]);
		$query_id->rows = array();
		return true;
	}

	// backslash style, sql_query() converts it to SQLite quoting
	function sql_escape($msg)
	{
		return addslashes($msg);
	}

	function sql_error($query_id = 0)
	{
		$result["message"] = $this->error_message;
		$result["code"] = $this->error_code;
		return $result;
	}

} // class sql_db

} // if ... define

?>
