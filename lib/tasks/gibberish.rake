namespace :gibberish do

    # Bela gambiarra
    desc "Exports all Gibberish translation keys"
    task :export do
        ENV['GIBBERISH_EXPORT'] = 'true'

        puts "Running tests ..."
        `rake test 2> /dev/null`

        puts "Sorting keys ..."
        $stderr.puts `sort lang/tmp_keys | uniq`

        `rm lang/tmp_keys`
    end
end
