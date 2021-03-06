require 'kit'

describe KitDBSupport do

  before :all do
    @config = {}
    @config[:sqlite3] = { adapter: 'sqlite3', database: 'spec_db.sqlite3' }
    @sqlite3 = @config[:sqlite3]
  end

  describe ".create!" do

    it "raises error if adapter not supported" do
      expect { KitDBSupport::create!(:adapter => 'bad_adapter') }.to raise_error RuntimeError, /not supported/
    end

    context "adapter is sqlite3" do

      it "creates the sqlite3 database file" do
        File.stub(:exists?).with(@sqlite3[:database]).and_return(false)
        SQLite3::Database.should_receive(:new).with(@sqlite3[:database])
        KitDBSupport::create! @config[:sqlite3]
      end

      it "raises error if sqlite3 database file exists" do
        File.stub(:exists?).with(@sqlite3[:database]).and_return(true)
        expect { KitDBSupport::create! @config[:sqlite3] }.to raise_error RuntimeError, /exists/
      end
    end
  end

  describe ".create" do
    it "calls .create!" do
      KitDBSupport.should_receive(:create!)
      KitDBSupport::create
    end

    it "does not raise error if sqlite3 database file exists" do
      File.stub(:exists?).with(@sqlite3[:database]).and_return(true)
      expect { KitDBSupport::create @config[:sqlite3] }.to_not raise_error
    end
  end

  describe ".destroy!" do

    it "raises error if adapter not supported" do
      expect { KitDBSupport::destroy!(:adapter => 'bad_adapter') }.to raise_error RuntimeError, /not supported/
    end

    context "adapter is sqlite3" do

      it "unlinks the sqlite3 databasefile " do
        File.stub(:exists?).with(@sqlite3[:database]).and_return(true)
        File.should_receive(:unlink).with( @sqlite3[:database] )
        KitDBSupport::destroy! @config[:sqlite3]
      end

      it "raises error if sqlite3 database file does not exist" do
        File.stub(:exists?).with(@sqlite3[:database]).and_return(false)
        expect { KitDBSupport::destroy! @config[:sqlite3] }.to raise_exception RuntimeError, /does not exist/
      end
    end
  end

  describe ".destroy" do
    it "calls .destroy!" do
      KitDBSupport.should_receive(:destroy!)
      KitDBSupport::destroy
    end

    it "does not raise error if sqlite3 database file does not exist" do
      File.stub(:exists?).with(@sqlite3[:database]).and_return(false)
      expect { KitDBSupport::destroy @config[:sqlite3] }.to_not raise_exception
    end
  end

  describe ".connect" do

    it "makes active record establish a connection" do
      ActiveRecord::Base.should_receive(:establish_connection).with(@config[:sqlite3])
      KitDBSupport::connect @config[:sqlite3]
    end
  end

  describe ".migrate" do

    it "migrates to latest version when called with no arguments" do
      ActiveRecord::Migrator.should_receive(:migrate)
      KitDBSupport::migrate 'migrations'
    end

    it "migrates one step in a given direction" do
      ActiveRecord::Migrator.should_receive(:up).with('migrations', 1)
      KitDBSupport::migrate 'migrations', :up
    end

    it "migrates many steps in a given direction" do
      ActiveRecord::Migrator.should_receive(:up).with('migrations', 3)
      KitDBSupport::migrate 'migrations', :up, 3
    end
  end

  describe ".migrate_to" do

    it "migrates to a specific migration" do
      ActiveRecord::Migrator.should_receive(:migrate).with('migrations', 001)
      KitDBSupport::migrate_to 'migrations', 001
    end
  end
end
