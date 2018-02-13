#include <Godot.hpp>

#include <Reference.hpp>

class Simple : public godot::GodotScript<godot::Reference> {
	GODOT_CLASS(Simple)
	
	godot::String data;
public:

	static void _register_methods(){
        godot::register_method("get_data", &Simple::get_data);
    }

	void _init() {
        data = "Hello World from C++";
    }

	godot::String get_data() const {
        return data;
    }
};

