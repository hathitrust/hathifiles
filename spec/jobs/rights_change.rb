# frozen_string_literal: true

RSpec.describe "bin/rights_change.sh" do
  it "writes the expected report file" do
    # Setup.
    Dir.chdir("/tmp")
    isodate = Time.now.strftime("%Y%m%d")
    # Command to run:
    cmd = [
      "bash",
      "/usr/src/app/bin/rights_change.sh",
      "/usr/src/app/spec/data/rights_change_file_1.txt",
      "/usr/src/app/spec/data/rights_change_file_2.txt"
    ].join(" ")
    # Expect this outfile
    outfile = "/tmp/ic_to_pd_#{isodate}.tsv"
    FileUtils.rm_f(outfile)
    expect(File.exist?(outfile)).to be false
    # Now do it.
    system(cmd)
    # Expect a file with a single line...
    expect(File.exist?(outfile)).to be true
    lines = File.read(outfile).split("\n")
    expect(lines.count).to eq 1
    # and that single line looks like this:
    expect(lines).to eq ["mdp.39015003746396\t0"]
    # Cleanup
    FileUtils.rm_f(outfile)
  end
end
