GLOBAL_DATUM_INIT(Singletons, /repository/singletons, new())

/repository/singletons
	/// A cache of individual singletons as (/singleton/path = Instance, ...)
	var/static/list/instances = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for instances.
	var/static/list/resolved_instances = list()

	/// A cache of singleton types according to a parent type as (/singleton/path = list(/singleton/path = Instance, /singleton/path/foo = Instance, ...))
	var/static/list/type_maps = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for type_maps.
	var/static/list/resolved_type_maps = list()

	/// A cache of singleton subtypes according to a parent type as (/singleton/path = list(/singleton/path/foo = Instance, ...))
	var/static/list/subtype_maps = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for subtype_maps.
	var/static/list/resolved_subtype_maps = list()

	/// A cache of singleton types according to a parent type as (/singleton/path = list(Parent Instance, Subtype Instance, ...))
	var/static/list/type_lists = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for type_lists.
	var/static/list/resolved_type_lists = list()

	/// A cache of singleton subtypes according to a parent type as (/singleton/path = list(Subtype Instance, Subtype Instance, ...))
	var/static/list/subtype_lists = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for subtype_lists.
	var/static/list/resolved_subtype_lists = list()


/**
* Get a singleton instance according to path. Creates it if necessary. Null if abstract or not a singleton.
* Prefer the GET_SINGLETON macro to minimize proc calls.
*/
/repository/singletons/proc/GetInstanceOf(singleton/path)
	if (!ispath(path, /singleton))
		return
	if (resolved_instances[path])
		return instances[path]
	resolved_instances[path] = TRUE
	if (is_abstract(path))
		return
	var/singleton/result = new path
	instances[path] = result
	result.Initialize()
	return result

/**
* Get a singleton instance according to object. Creates it if necessary. Null if abstract or not a singleton.
* Prefer the GET_SINGLETON macro to minimize proc calls.
* WARNING: this is NOT the one from Bay, use GetInstanceOf for that!
*/

/repository/singletons/proc/GetInstance(singleton/decl_type)
	if (resolved_instances[decl_type.type])
		return instances[decl_type.type]
	resolved_instances[decl_type.type] = TRUE

	var/singleton/result = instances[decl_type.type]
	if(!result)
		result = new decl_type()
		instances[decl_type.type] = result

		var/singleton/decl = result
		if(istype(decl))
			decl.Initialize()
	return result


/// Get a (path = instance) map of valid singletons according to paths.
/repository/singletons/proc/GetMap(list/singleton/paths)
	var/list/result = list()
	for (var/path in paths)
		var/singleton/instance = GetInstanceOf(path)
		if (!instance)
			continue
		result[path] = instance
	return result


/// Get a list of valid singletons according to paths.
/repository/singletons/proc/GetList(list/singleton/paths)
	var/list/result = list()
	for (var/path in paths)
		var/singleton/instance = GetInstanceOf(path)
		if (!instance)
			continue
		result += instance
	return result


/**
* Get a (path = instance) map of valid singletons according to typesof(path).
* Prefer the GET_SINGLETON_TYPE_MAP macro to minimize proc calls.
*/
/repository/singletons/proc/GetTypeMap(singleton/path)
	if (resolved_type_maps[path])
		return type_maps[path] || list()
	resolved_type_maps[path] = TRUE
	var/result = GetMap(typesof(path))
	type_maps[path] = result
	return result


/**
* Get a (path = instance) map of valid singletons according to subtypesof(path).
* Prefer the GET_SINGLETON_TYPE_MAP macro to minimize proc calls.
*/
/repository/singletons/proc/GetSubtypeMap(singleton/path)
	if (resolved_subtype_maps[path])
		return subtype_maps[path] || list()
	resolved_subtype_maps[path] = TRUE
	var/result = GetMap(subtypesof(path))
	subtype_maps[path] = result
	return result


/**
* Get a list of valid singletons according to typesof(path).
* Prefer the GET_SINGLETON_TYPE_LIST macro to minimize proc calls.
*/
/repository/singletons/proc/GetTypeList(singleton/path)
	if (resolved_type_lists[path])
		return type_lists[path] || list()
	resolved_type_lists[path] = TRUE
	var/result = GetList(typesof(path))
	type_lists[path] = result
	return result


/**
* Get a list of valid singletons according to subtypesof(path).
* Prefer the GET_SINGLETON_SUBTYPE_MAP macro to minimize proc calls.
*/
/repository/singletons/proc/GetSubtypeListOf(singleton/path)
	if (resolved_subtype_lists[path])
		return subtype_lists[path] || list()
	resolved_subtype_lists[path] = TRUE
	var/result = GetList(subtypesof(path))
	subtype_lists[path] = result
	return result


/**
* Get a list of valid singletons according to subtypesof(type).
* Prefer the GET_SINGLETON_SUBTYPE_MAP macro to minimize proc calls.
* WARNING: this is NOT the one from Bay, use GetSubtypeListOf for that!
*/
/repository/singletons/proc/GetSubtypeList(singleton/decl_prototype)
	if (resolved_subtype_lists[decl_prototype.type])
		return subtype_lists[decl_prototype.type] || list()
	resolved_subtype_lists[decl_prototype.type] = TRUE

	var/singleton/result = subtype_lists[decl_prototype.type]
	if(!result)
		result = GetList(subtypesof(decl_prototype.type))
		subtype_lists[decl_prototype.type] = result
	return result


ABSTRACT_TYPE(/singleton)


/singleton/proc/Initialize()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)


/singleton/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	crash_with("Prevented attempt to delete a singleton instance: [log_info_line(src)]")
	return QDEL_HINT_LETMELIVE
