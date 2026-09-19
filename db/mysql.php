<?php
/***************************************************************************
 *                                 mysql.php
 *                            -------------------
 *   begin                : Saturday, Feb 13, 2001
 *   copyright            : (C) 2001 The phpBB Group
 *   email                : support@phpbb.com
 *
 *   Ported to mysqli for PHP 8.
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

define("SQL_LAYER","mysql");

class sql_db
{
	var $db_connect_id;
	var $query_result;
	var $row = array();
	var $rowset = array();
	var $num_queries = 0;
	var $persistency;
	var $user;
	var $password;
	var $server;
	var $dbname;

	function __construct($sqlserver, $sqluser, $sqlpassword, $database, $persistency = true)
	{
		$this->persistency = $persistency;
		$this->user = $sqluser;
		$this->password = $sqlpassword;
		$this->server = $sqlserver;
		$this->dbname = $database;

		mysqli_report(MYSQLI_REPORT_OFF);

		$port = null;
		if (strpos($sqlserver, ':') !== false)
		{
			list($sqlserver, $port) = explode(':', $sqlserver, 2);
			$port = (int) $port;
		}
		if ($persistency)
		{
			$sqlserver = 'p:' . $sqlserver;
		}

		$this->db_connect_id = @mysqli_connect($sqlserver, $sqluser, $sqlpassword, $database, $port);
		if (!$this->db_connect_id)
		{
			$this->db_connect_id = false;
			return;
		}
	}

	function sql_close()
	{
		if (!$this->db_connect_id)
		{
			return false;
		}
		if ($this->query_result instanceof mysqli_result)
		{
			@mysqli_free_result($this->query_result);
		}
		return @mysqli_close($this->db_connect_id);
	}

	function sql_query($query = "", $transaction = FALSE)
	{
		unset($this->query_result);
		if ($query != "")
		{
			$this->num_queries++;
			$this->query_result = @mysqli_query($this->db_connect_id, $query);
		}
		if (!$this->query_result)
		{
			return ( $transaction == END_TRANSACTION ) ? true : false;
		}
		$key = $this->_key($this->query_result);
		unset($this->row[$key]);
		unset($this->rowset[$key]);
		return $this->query_result;
	}

	function _key($query_id)
	{
		return is_object($query_id) ? spl_object_id($query_id) : (int) $query_id;
	}

	function _result($query_id)
	{
		if (!$query_id)
		{
			$query_id = $this->query_result;
		}
		return ($query_id instanceof mysqli_result) ? $query_id : false;
	}

	function sql_numrows($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		return $query_id ? @mysqli_num_rows($query_id) : false;
	}

	function sql_affectedrows()
	{
		return $this->db_connect_id ? @mysqli_affected_rows($this->db_connect_id) : false;
	}

	function sql_numfields($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		return $query_id ? @mysqli_num_fields($query_id) : false;
	}

	function sql_fieldname($offset, $query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id)
		{
			return false;
		}
		$field = @mysqli_fetch_field_direct($query_id, $offset);
		return $field ? $field->name : false;
	}

	function sql_fieldtype($offset, $query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id)
		{
			return false;
		}
		$field = @mysqli_fetch_field_direct($query_id, $offset);
		if (!$field)
		{
			return false;
		}
		// approximate the old mysql_field_type() names
		switch ($field->type)
		{
			case MYSQLI_TYPE_TINY:
			case MYSQLI_TYPE_SHORT:
			case MYSQLI_TYPE_LONG:
			case MYSQLI_TYPE_INT24:
			case MYSQLI_TYPE_LONGLONG:
				return 'int';
			case MYSQLI_TYPE_FLOAT:
			case MYSQLI_TYPE_DOUBLE:
			case MYSQLI_TYPE_DECIMAL:
			case MYSQLI_TYPE_NEWDECIMAL:
				return 'real';
			case MYSQLI_TYPE_BLOB:
			case MYSQLI_TYPE_TINY_BLOB:
			case MYSQLI_TYPE_MEDIUM_BLOB:
			case MYSQLI_TYPE_LONG_BLOB:
				return 'blob';
			case MYSQLI_TYPE_TIMESTAMP:
				return 'timestamp';
			case MYSQLI_TYPE_DATE:
				return 'date';
			case MYSQLI_TYPE_DATETIME:
				return 'datetime';
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
		$row = @mysqli_fetch_array($query_id, MYSQLI_BOTH);
		$this->row[$this->_key($query_id)] = $row;
		return ($row === null) ? false : $row;
	}

	function sql_fetchrowset($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id)
		{
			return false;
		}
		$key = $this->_key($query_id);
		unset($this->rowset[$key]);
		unset($this->row[$key]);
		$result = array();
		while ($this->rowset[$key] = @mysqli_fetch_array($query_id, MYSQLI_BOTH))
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
		$key = $this->_key($query_id);
		$result = false;
		if ($rownum > -1)
		{
			if (@mysqli_data_seek($query_id, $rownum))
			{
				$row = @mysqli_fetch_array($query_id, MYSQLI_BOTH);
				$result = isset($row[$field]) ? $row[$field] : false;
			}
			return $result;
		}
		if (empty($this->row[$key]) && empty($this->rowset[$key]))
		{
			if ($this->sql_fetchrow($query_id))
			{
				$result = $this->row[$key][$field];
			}
		}
		else if (!empty($this->rowset[$key]))
		{
			$result = $this->rowset[$key][0][$field];
		}
		else if (!empty($this->row[$key]))
		{
			$result = $this->row[$key][$field];
		}
		return $result;
	}

	function sql_rowseek($rownum, $query_id = 0)
	{
		$query_id = $this->_result($query_id);
		return $query_id ? @mysqli_data_seek($query_id, $rownum) : false;
	}

	function sql_nextid()
	{
		return $this->db_connect_id ? @mysqli_insert_id($this->db_connect_id) : false;
	}

	function sql_freeresult($query_id = 0)
	{
		$query_id = $this->_result($query_id);
		if (!$query_id)
		{
			return false;
		}
		$key = $this->_key($query_id);
		unset($this->row[$key]);
		unset($this->rowset[$key]);
		@mysqli_free_result($query_id);
		return true;
	}

	function sql_escape($msg)
	{
		return $this->db_connect_id ? mysqli_real_escape_string($this->db_connect_id, $msg) : addslashes($msg);
	}

	function sql_error($query_id = 0)
	{
		$result["message"] = $this->db_connect_id ? @mysqli_error($this->db_connect_id) : @mysqli_connect_error();
		$result["code"] = $this->db_connect_id ? @mysqli_errno($this->db_connect_id) : @mysqli_connect_errno();
		return $result;
	}

} // class sql_db

} // if ... define

?>
