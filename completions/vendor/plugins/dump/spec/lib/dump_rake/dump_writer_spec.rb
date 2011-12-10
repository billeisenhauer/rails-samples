require File.dirname(__FILE__) + '/../../spec_helper'

require File.dirname(__FILE__) + '/../../../lib/dump_rake'
require File.dirname(__FILE__) + '/../../../lib/dump_rake/dump_writer'

DumpWriter = DumpRake::DumpWriter
describe DumpWriter do
  describe "create" do
    it "should create selves instance and open" do
      @dump = mock('dump')
      @dump.should_receive(:open)
      DumpWriter.should_receive(:new).with('/abc/123.tmp').and_return(@dump)
      DumpWriter.create('/abc/123.tmp')
    end

    it "should call dump subroutines" do
      @dump = mock('dump')
      @dump.stub!(:open).and_yield(@dump)
      DumpWriter.stub!(:new).and_return(@dump)

      @dump.should_receive(:write_schema).ordered
      @dump.should_receive(:write_tables).ordered
      @dump.should_receive(:write_assets).ordered
      @dump.should_receive(:write_config).ordered

      DumpWriter.create('/abc/123.tmp')
    end
  end

  describe "open" do
    it "should create dir for dump" do
      Zlib::GzipWriter.stub!(:open)
      FileUtils.should_receive(:mkpath).with('/abc/def/ghi')
      DumpWriter.new('/abc/def/ghi/123.tgz').open
    end

    it "should set stream to gzipped tar writer" do
      FileUtils.stub!(:mkpath)
      @gzip = mock('gzip')
      @stream = mock('stream')
      Zlib::GzipWriter.should_receive(:open).with(Pathname("123.tgz")).and_yield(@gzip)
      Archive::Tar::Minitar::Output.should_receive(:open).with(@gzip).and_yield(@stream)
      @gzip.should_receive(:mtime=).with(Time.utc(2000))

      @dump = DumpWriter.new('123.tgz')
      @dump.should_receive(:lock).and_yield
      @dump.open do |dump|
        dump.should == @dump
        dump.stream.should == @stream
      end
    end
  end

  describe "subroutines" do
    before do
      @tar = mock('tar')
      @stream = mock('stream', :tar => @tar)
      @config = {:tables => {}}
      @dump = DumpWriter.new('123.tgz')
      @dump.stub!(:stream).and_return(@stream)
      @dump.stub!(:config).and_return(@config)
      Progress.stub!(:io).and_return(StringIO.new)
    end

    describe "create_file" do
      it "should create temp file, yield it for writing, create file in tar and write it there" do
        @temp = mock('temp', :open => true, :length => 6, :read => 'qwfpgj')
        @temp.should_receive(:write).with('qwfpgj')
        @temp.stub!(:eof?).and_return(false, true)
        Tempfile.should_receive(:open).and_yield(@temp)

        @file = mock('file')
        @file.should_receive(:write).with('qwfpgj')

        @stream.tar.should_receive(:add_file_simple).with('abc/def.txt', :mode => 0100444, :size => 6).and_yield(@file)

        @dump.create_file('abc/def.txt') do |file|
          file.should == @temp
          file.write('qwfpgj')
        end
      end
    end

    describe "write_schema" do
      it "should create file schema.rb" do
        @dump.should_receive(:create_file).with('schema.rb')
        @dump.write_schema
      end

      it "should set ENV[SCHEMA] to path of returned file" do
        @file = mock('file', :path => 'db/schema.rb')
        @dump.stub!(:create_file).and_yield(@file)
        DumpRake::Env.should_receive(:with_env).with('SCHEMA' => 'db/schema.rb')
        @dump.write_schema
      end

      it "should call rake task db:schema:dump" do
        @file = mock('file', :path => 'db/schema.rb')
        @dump.stub!(:create_file).and_yield(@file)
        @task = mock('task')
        Rake::Task.should_receive(:[]).with('db:schema:dump').and_return(@task)
        @task.should_receive(:invoke)
        @dump.write_schema
      end
    end

    describe "write_tables" do
      it "should verify connection" do
        @dump.stub!(:tables_to_dump).and_return([])
        @dump.should_receive(:verify_connection)
        @dump.write_tables
      end

      it "should call write_table for each table returned by tables_to_dump" do
        @dump.stub!(:verify_connection)
        @dump.stub!(:tables_to_dump).and_return(%w(first second))

        @dump.should_receive(:write_table).with('first')
        @dump.should_receive(:write_table).with('second')

        @dump.write_tables
      end
    end

    describe "write_table" do
      it "should get row count and store it to config" do
        @dump.should_receive(:table_row_count).with('first').and_return(666)
        @dump.stub!(:create_file)
        @dump.write_table('first')
        @config[:tables]['first'].should == 666
      end

      it "should create_file" do
        @dump.stub!(:table_row_count).and_return(666)
        @dump.should_receive(:create_file)
        @dump.write_table('first')
      end

      it "should dump column names and values of each row" do
        @column_definitions = [
          mock('column', :name => 'id'),
          mock('column', :name => 'name'),
          mock('column', :name => 'associated_id')
        ]
        ActiveRecord::Base.connection.stub!(:columns).and_return(@column_definitions)
        @rows = [
          {'id' => 1, 'name' => 'a', 'associated_id' => 100},
          {'id' => 2, 'name' => 'b', 'associated_id' => 666},
        ]

        @file = mock('file')
        @dump.stub!(:table_row_count).and_return(666)
        @dump.stub!(:create_file).and_yield(@file)

        column_names = @column_definitions.map(&:name).sort
        @file.should_receive(:write).with(Marshal.dump(column_names)).ordered
        each_tabler_row_yielder = @dump.should_receive(:each_table_row)
        @rows.each do |row|
          each_tabler_row_yielder.and_yield(row)
          @file.should_receive(:write).with(Marshal.dump(row.values_at(*column_names))).ordered
          @column_definitions.each do |column_definition|
            column_definition.should_receive(:type_cast).with(row[column_definition.name]).and_return(row[column_definition.name])
          end
        end

        @dump.write_table('first')
      end
    end

    describe "write_assets" do
      before do
        @dump.stub!(:assets_root_link).and_yield('/tmp', 'assets')
      end

      it "should call assets_to_dump" do
        @dump.should_receive(:assets_to_dump).and_return([])
        @dump.write_assets
      end

      it "should change root to RAILS_ROOT" do
        @file = mock('file')
        @dump.stub!(:assets_to_dump).and_return(%w(images videos))
        @dump.stub!(:create_file).and_yield(@file)

        Dir.should_receive(:chdir).with(RAILS_ROOT)
        @dump.write_assets
      end

      it "should put assets to config" do
        @file = mock('file')
        @dump.stub!(:assets_to_dump).and_return(%w(images/* videos))
        @dump.stub!(:create_file).and_yield(@file)
        Dir.stub!(:chdir).and_yield
        @tar = mock('tar_writer')
        Archive::Tar::Minitar::Output.stub!(:open).and_yield(@tar)
        Dir.stub!(:[]).and_return([])
        Dir.should_receive(:[]).with(*%w(images/* videos)).and_return(%w(images/a images/b videos))

        @dump.write_assets
        counts = {:files => 0, :total => 0}
        @config[:assets].should == {'images/a' => counts, 'images/b' => counts, 'videos' => counts}
      end

      it "should use glob to find files" do
        @file = mock('file')
        @dump.stub!(:assets_to_dump).and_return(%w(images/* videos))
        @dump.stub!(:create_file).and_yield(@file)
        Dir.stub!(:chdir).and_yield
        @tar = mock('tar_writer')
        Archive::Tar::Minitar::Output.stub!(:open).and_yield(@tar)

        Dir.should_receive(:[]).with(*%w(images/* videos)).and_return(%w(images/a images/b videos))
        Dir.should_receive(:[]).with('images/a/**/*').and_return([])
        Dir.should_receive(:[]).with('images/b/**/*').and_return([])
        Dir.should_receive(:[]).with('videos/**/*').and_return([])

        @dump.write_assets
      end

      it "should pack each file from assets_root_link" do
        @file = mock('file')
        @dump.stub!(:assets_to_dump).and_return(%w(images/* videos))
        @dump.stub!(:create_file).and_yield(@file)
        Dir.stub!(:chdir).and_yield
        @tar = mock('tar_writer')
        Archive::Tar::Minitar::Output.stub!(:open).and_yield(@tar)

        Dir.should_receive(:[]).with(*%w(images/* videos)).and_return(%w(images/a images/b videos))
        Dir.should_receive(:[]).with('images/a/**/*').and_return([])
        Dir.should_receive(:[]).with('images/b/**/*').and_return([])
        Dir.should_receive(:[]).with('videos/**/*').and_return([])

        @dump.should_receive(:assets_root_link).exactly(3).times

        @dump.write_assets
      end

      it "should pack each file" do
        @file = mock('file')
        @dump.stub!(:assets_to_dump).and_return(%w(images/* videos))
        @dump.stub!(:create_file).and_yield(@file)
        Dir.stub!(:chdir).and_yield
        @tar = mock('tar_writer')
        Archive::Tar::Minitar::Output.stub!(:open).and_yield(@tar)

        Dir.should_receive(:[]).with(*%w(images/* videos)).and_return(%w(images/a images/b videos))
        Dir.should_receive(:[]).with('images/a/**/*').and_return(%w(a.jpg b.jpg))
        Dir.should_receive(:[]).with('images/b/**/*').and_return(%w(c.jpg d.jpg))
        Dir.should_receive(:[]).with('videos/**/*').and_return(%w(a.mov b.mov))

        %w(a.jpg b.jpg c.jpg d.jpg a.mov b.mov).each do |file_name|
          Archive::Tar::Minitar.should_receive(:pack_file).with("assets/#{file_name}", @stream)
        end

        @dump.write_assets
      end

      it "should not raise if something fails when packing" do
        @file = mock('file')
        @dump.stub!(:assets_to_dump).and_return(%w(videos))
        @dump.stub!(:create_file).and_yield(@file)
        Dir.stub!(:chdir).and_yield
        @tar = mock('tar_writer')
        Archive::Tar::Minitar::Output.stub!(:open).and_yield(@tar)

        Dir.should_receive(:[]).with(*%w(videos)).and_return(%w(videos))
        Dir.should_receive(:[]).with('videos/**/*').and_return(%w(a.mov b.mov))

        Archive::Tar::Minitar.should_receive(:pack_file).with('assets/a.mov', @stream).and_raise('file not found')
        Archive::Tar::Minitar.should_receive(:pack_file).with('assets/b.mov', @stream)

        grab_output {
          @dump.write_assets
        }
      end

    end

    describe "write_config" do
      it "should create file config" do
        @dump.should_receive(:create_file).with('config')
        @dump.write_config
      end

      it "should dump column names and values of each row" do
        @file = mock('file')
        @dump.stub!(:create_file).and_yield(@file)
        @config.replace({:tables => {'first' => 1, 'second' => 2}, :assets => %w(images videos)})

        @file.should_receive(:write).with(Marshal.dump(@config))
        @dump.write_config
      end
    end

    describe "assets_to_dump" do
      it "should call rake task assets" do
        @task = mock('task')
        Rake::Task.should_receive(:[]).with('assets').and_return(@task)
        @task.should_receive(:invoke)
        @dump.assets_to_dump
      end

      it "should return array of assets if separator is colon" do
        @task = mock('task')
        Rake::Task.stub!(:[]).and_return(@task)
        @task.stub!(:invoke)
        DumpRake::Env.with_env(:assets => 'images:videos') do
          @dump.assets_to_dump.should == %w(images videos)
        end
      end

      it "should return array of assets if separator is comma" do
        @task = mock('task')
        Rake::Task.stub!(:[]).and_return(@task)
        @task.stub!(:invoke)
        DumpRake::Env.with_env(:assets => 'images,videos') do
          @dump.assets_to_dump.should == %w(images videos)
        end
      end

      it "should return empty array if calling rake task assets raises an exception" do
        Rake::Task.stub!(:[]).and_raise('task assets not found')
        DumpRake::Env.with_env(:assets => 'images:videos') do
          @dump.assets_to_dump.should == []
        end
      end
    end
  end
end
