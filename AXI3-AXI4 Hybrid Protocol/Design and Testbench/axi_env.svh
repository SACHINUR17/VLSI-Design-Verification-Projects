class axi_env;
  axi_gen gen;
  axi_bfm bfm;
  axi_mon mon;
  axi_cov cov;
  
  function new();
    gen = new();
    bfm = new();
    mon = new();
    cov = new();
  endfunction
  
  task run();
    fork
    gen.run();
    bfm.run();
    mon.run();
    cov.run();
    join
  endtask
endclass
