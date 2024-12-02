## Disk Management and Logical Volume Setup 
### Attach a 15GB disk to VM.  
![disk first](https://github.com/user-attachments/assets/e98cc162-6be6-44bc-a300-0b1d8501be1d)  
------------------------------
###  Partition the 15GB Disk into 4 Partitions
1. **partitions will be created as:**
   1. /dev/sdb1 (5GB)
   2. /dev/sdb2 (5GB)
   3. /dev/sdb3 (3GB)
   4. /dev/sdb4 (2GB)
using `fdisk /dev/sdb`

![partation disk](https://github.com/user-attachments/assets/c6d4fe49-966d-4f3b-af0e-5382d50cf84a)
------------------------------------------------
### Format the Partitions
1. **Format the First 5GB Partition as ext4**  
`sudo mkfs.ext4 /dev/sdb1`  

2. **Set Up the 2GB Partition as Swap**  
`sudo mkswap /dev/sdb4`  
`sudo swapon /dev/sdb4`  

![swap](https://github.com/user-attachments/assets/12b73f6c-46a5-4982-be95-f3830c9b3cb4)  
--------------------------------------
### Set Up LVM on the Remaining Partitions (5GB and 3GB)  
1. **Create Physical Volumes (PVs)**  
   `sudo pvcreate /dev/sdb2`    
   `sudo pvcreate /dev/sdb3`    

3. **Create a Volume Group (VG):**  
   `sudo vgcreate my_volume_group /dev/sdb2`   

   ![vg before extend](https://github.com/user-attachments/assets/0e43f457-123f-4b9b-aa48-005182125bc8)   

3. **Create a Logical Volume (LV):**  
   `sudo lvcreate --size +5G --name my_logical_volume my_volume_group`  
  
   ![lv before](https://github.com/user-attachments/assets/05461e0a-c488-4d21-8b25-fa602d7aa2de)   
------
### Extend the Logical Volume with the 3GB Partition  
1. **Add /dev/sdb3 to the Volume Group:**   
   ` sudo vgextend my_volume_group /dev/sdb3`
   
   ![vg after](https://github.com/user-attachments/assets/09e48e77-f405-490f-a27c-76e5d2fb21eb)

2. **Extend the Logical Volume:**   
    `sudo lvextend -L +3G /dev/my_volume_group/my_logical_volume`
   ![lv after](https://github.com/user-attachments/assets/2a2a570b-8ead-404f-b79c-7f7c2c99e406)
----------------------------
### Mount Volumes  
 `mount /dev/my_volume_group/my_logical_volume /mydata`  
 
 ![mount](https://github.com/user-attachments/assets/974ae1d2-515a-4480-8065-f1bd55d3764d)    


 ### Permanent Mount   
 1. **Get the UUID of the Partition or Volume**   
   ` sudo blkid /dev/my_volume_group/my_logical_volume  `
 
 2. **Edit the /etc/fstab File**  
    ` sudo vim /etc/fstab`

 3. **Add an entry for the mount**  
   ` UUID=8081551e-a180-4ca5-be17-3664d8dd2395 /mydata ext4 defaults 0 2`

 



   








