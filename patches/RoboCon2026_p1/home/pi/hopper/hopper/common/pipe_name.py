import os

from .pipe_type import PipeType

class PipeName:
    __type = None
    __handler_id = None
    __id = None
    __root = ""

    def __init__(self, x, root = ""):
        self.__root = root

        if type(x) is str:
            self.__from_str(x)
        elif type(x) is tuple:
            self.__from_tuple(x)
        else:
            raise ValueError("Invalid pipe name object.")

    def __from_str(self, s):
        p = s.split("_")
        self.__type = (PipeType.INPUT if p[0] == 'I' else PipeType.OUTPUT)
        self.__handler_id = p[1]
        self.__id = p[2]

    def __from_tuple(self, t):
        self.__type = t[0]
        self.__handler_id = t[1]
        self.__id = t[2]

    def __str__(self):
        return f"{'I' if self.__type == PipeType.INPUT else 'O'}_{self.__handler_id}_{self.__id}"
    
    def __eq__(self, pn):
        if not isinstance(pn, PipeName):
            return NotImplemented
        return (str(pn) == str(self)) and (pn.root_path == self.__root)

    @property
    def pipe_path(self):
        return os.path.join(self.__root, str(self))
    
    @property
    def type(self):
        return self.__type
    
    @property
    def handler_id(self):
        return self.__handler_id
    
    @property
    def id(self):
        return self.__id
    
    @property
    def root_path(self):
        return self.__root

