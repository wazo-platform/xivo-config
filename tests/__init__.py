from importlib.machinery import SourceFileLoader
from importlib.util import spec_from_loader, module_from_spec
from os import path


def load_from_sbin(file_name: str):
    loader = SourceFileLoader(file_name.replace('-', '_'), path.join('sbin', file_name))
    spec = spec_from_loader(loader.name, loader)
    module = module_from_spec(spec)
    loader.exec_module(module)
    return module
