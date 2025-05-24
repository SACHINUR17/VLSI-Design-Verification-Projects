AXI (Advanced eXtensible Interface) protocol
AXI is a high-performance, high-bandwidth protocol designed for connecting high-performance IP components, such as processors and memory controllers. It is designed to support the needs of high-frequency, high-throughput systems while providing features to ensure data integrity and minimize latency. AXI has several versions, including AXI4 and AXI4-Lite, each with specific characteristics. AXI features include:

Separate read and write channels to allow concurrent data transfers.
Support for out-of-order transactions to improve efficiency.
Burst transfers for efficient data movement.
Multiple transaction types (read, write, exclusive, etc.).
Support for multiple outstanding transactions to maximize throughput.
AXI slave operation
Write :

write operation timing diagram.

<img width="341" alt="264765479-46f83d64-3927-44bb-866b-a490fca5dbb0" src="https://github.com/user-attachments/assets/26a5f283-f3ba-4305-a67f-dba24a8a4d83" />

Read :

read operation timing diagram.

<img width="342" alt="264766072-fcc3da14-5469-49a3-9508-d881a8b45a2f" src="https://github.com/user-attachments/assets/14ee81cd-dbe8-4349-8995-ce085fa59708" />

AXI slave design using verilog RTL
axi_slave.v : AXI slave interface design file
Read channel
ARADDR : Specifies the address for a read transaction.
ARLEN : Indicates the number of data transfers within a read burst.
ARSIZE : Specifies the size of each data transfer in a read burst.
ARBURST : Specifies the type of read burst (e.g., incrementing, wrapping).
ARVALID : Indicates that valid read address information is available.
ARREADY : Indicates that the slave is ready to accept the read address.
RDATA : Carries the data read from the slave.
RRESP : Indicates the response status of the read transaction (e.g., OKAY[1], ERROR[0]).
RLAST : Indicates the last data beat in a read burst.
RVALID : Indicates that valid read data is available.
RREADY : Indicates that the master is ready to accept the read data.
Write channel
AWADDR : Specifies the address for a write transaction.
AWLEN : Indicates the number of data transfers within a write burst.
AWSIZE : Specifies the size of each data transfer in a write burst.
AWBURST : Specifies the type of write burst (e.g., incrementing, wrapping).
AWVALID : Indicates that valid write address information is available.
AWREADY : Indicates that the slave is ready to accept the write address.
WDATA : Carries the data to be written by the master.
WLAST : Indicates the last data beat in a write burst.
WVALID : Indicates that valid write data is available.
WREADY : Indicates that the slave is ready to accept the write data.
BRESP : Indicates the response status of the write transaction (e.g., OKAY, ERROR).
BVALID : Indicates that a valid write response is available.
BREADY : Indicates that the master is ready to accept the write response.
axi_slave_tb.v : Testbench file.
Simulation Results
![Screenshot 2025-05-15 231446](https://github.com/user-attachments/assets/1f14fc86-b3f1-407e-bdfc-410ebf82f8eb)

![Screenshot 2025-05-15 232304](https://github.com/user-attachments/assets/8c4efa9d-846f-4abe-a5b4-5a0e0d94d42f)
