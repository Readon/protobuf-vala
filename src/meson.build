protobuf_vala_lib = static_library('protobuf_vala', ['protobuf-vala.vala'],
        dependencies : [glib_dep, gobject_dep],
        install: false)
protobuf_vala_dep = declare_dependency(link_with: protobuf_vala_lib)

protoc_gen_vala = executable('protoc-gen-vala', ['protoc-gen-vala.vala', 'descriptor.pb.vala', 'plugin.pb.vala'],
        c_args : '-DVERSION=0.2',
        dependencies : [protobuf_vala_dep, posix_dep, glib_dep, gobject_dep],
        install: true)
