using HTTP
using JSON
using InteractNext
using WebIO

# Define the function for calculating the frequency list
function calculate_frequency_list(engine_speed, num_cylinders, duration)
    fundamental_frequency = (engine_speed / 60) * (num_cylinders / 2)
    frequency_list = [fundamental_frequency * i for i in 1:10]
    return frequency_list
end

# Define the function for creating the sound file
function create_sound_file(frequency_list, duration)
    # Send a POST request to the server to create the sound file
    res = HTTP.post("/create_sound_file", JSON.json(["frequency_list" => frequency_list, "duration" => duration]))
    # Save the sound file to disk
    open("diesel_car_sound.mp3", "w") do f
        write(f, res.body)
    end
end

# Define the function for creating the HTML file
function create_html_file()
    # Define the widgets
    engine_speed_widget = slider(1000:100:5000, label="Engine Speed (RPM)")
    num_cylinders_widget = slider(2:2:16, label="Number of Cylinders")
    duration_widget = slider(0.5:0.5:5.0, label="Duration (s)")

    # Define the callback for the calculate frequency list button
    calculate_callback = () -> begin
        engine_speed = Int(engine_speed_widget[]); num_cylinders = Int(num_cylinders_widget[]); duration = duration_widget[]
        frequency_list = calculate_frequency_list(engine_speed, num_cylinders, duration)
        frequency_list_input[] = JSON.json(frequency_list)
        create_sound_file_button[]["attributes"]["disabled"] = nothing
    end

    # Define the callback for the create sound file button
    create_sound_file_callback = () -> begin
        frequency_list = JSON.parse(frequency_list_input[]); duration = duration_widget[]
        create_sound_file(frequency_list, duration)
    end

    # Create the HTML page
    page = html_output(
        body = VBox(
            h1("Diesel Car Sound Frequency Calculator"),
            p("Enter the engine speed (in RPM), the number of cylinders, and the duration (in seconds):"),
            label("Engine Speed (RPM): ", engine_speed_widget),
            label("Number of Cylinders: ", num_cylinders_widget),
            label("Duration (s): ", duration_widget),
            button("Calculate Frequency List", onclick=calculate_callback),
            input(type="hidden", id="frequency_list_input"),
            button("Create Sound File", onclick=create_sound_file_callback, attributes=Dict("disabled"=>"disabled"))
        )
    )

    # Write the HTML page to disk
    WebIO.write(page, "diesel_car_sound_frequency.html")
end

# Create the HTML file
create_html_file()
