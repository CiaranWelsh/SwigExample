%module swig_example

%{

#define SWIG_FILE_WITH_INIT
#include "SwigExample.h"

%}

%include "std_string.i"
%include "std_unordered_map.i"
%include "std_vector.i"

%template(StringVector) std::vector<std::string>;
%template(IntVector) std::vector<int>;

%typemap(out) SpecialFooMap* {
    // marker for SpecialFooMap
    $result = PyDict_New();
    if (!$result){
        std::string err = "Could not create dict object";
        PyErr_SetString(PyExc_ValueError, err.c_str());
    }
    for (auto& [fooName, fooUniquePtr]: $1->map_){
        // release ownership from the unique_ptr.
        Foo* fooPtr = fooUniquePtr.release();
        // give it to swig
        PyObject* swigOwnedPtr = SWIG_NewPointerObj(
                SWIG_as_voidptr(fooPtr),
                $descriptor(Foo*),
                /*SWIG_POINTER_NEW |  SWIG_POINTER_NOSHADOW*/
                SWIG_POINTER_NEW |  0
        );
        if (!swigOwnedPtr){
            PyErr_SetString(PyExc_ValueError, "Could not create a swig wrapped RoadRunner object from "
                                        "a std::unique_ptr<RoadRunner>");
        }
        int failed = PyDict_SetItem($result, PyUnicode_FromString(fooName.c_str()), swigOwnedPtr);
        if (failed){
            PyErr_SetString(PyExc_ValueError, "Could not create item in dict");
        }
    }
}

%ignore SpecialFooMap::map_;
%include "SwigExample.h"

%extend Foo {
    %pythoncode %{
        def __str__(self):
            return f"<class '{type(self)}'>"
     %}
}




